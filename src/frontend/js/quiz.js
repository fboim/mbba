/**
 * quiz.js — Modular Quiz Logic v3
 *
 * Perubahan dari v2:
 * - Jumlah soal bisa dikonfigurasi per fasal (quiz_count)
 * - 3 tipe soal: mc / fill-arab / fill-latin
 * - Scoring 100% threshold
 *
 * Passing threshold : 100%
 * Max retry        : unlimited (acak ulang setiap kali)
 */

const PASSING_THRESHOLD = 100;
const DEFAULT_QUESTIONS = 10;

// ================================================================
// QUIZ STATE
// ================================================================

let quizQuestions = [];
let currentQuestionIndex = 0;
let answeredQuestions = {};
let quizBankLoaded = [];
let currentFasal = null;
let currentBab = null;
let quizBank = [];

function shuffleQuiz(bank, count = DEFAULT_QUESTIONS) {
  const shuffled = [...bank].sort(() => Math.random() - 0.5);
  return shuffled.slice(0, Math.min(count, bank.length));
}

function initQuiz(bank, fasalId, count = DEFAULT_QUESTIONS, callbacks = {}) {
  const questions = shuffleQuiz(bank, count);
  window._quizState = {
    questions,
    fasalId,
    count,
    selectedAnswers: {},
    submitted: false,
    callbacks
  };
  return questions;
}

function submitQuiz() {
  const state = window._quizState;
  if (!state) throw new Error('Quiz not initialized. Call initQuiz() first.');
  if (state.submitted) return;

  state.submitted = true;
  let correct = 0;
  const results = [];

  state.questions.forEach(q => {
    const userAnswer = normalizeAnswer(state.selectedAnswers[q.id], q.type);
    const correctAnswer = normalizeAnswer(q.correct_answer, q.type);
    const isCorrect = userAnswer === correctAnswer;
    if (isCorrect) correct++;

    results.push({
      questionId: q.id,
      type: q.type,
      isCorrect,
      userAnswer: state.selectedAnswers[q.id] || '',
      correctAnswer: q.correct_answer
    });
  });

  const score = Math.round((correct / state.questions.length) * 100);
  const passed = score >= PASSING_THRESHOLD;

  if (passed && state.callbacks.onPass) {
    state.callbacks.onPass(score, correct, state.questions.length, results);
  } else if (!passed && state.callbacks.onFail) {
    state.callbacks.onFail(score, correct, state.questions.length, results);
  }

  return { score, passed, correct, total: state.questions.length, results };
}

window.submitQuizResult = submitQuiz;

function normalizeAnswer(answer, type) {
  if (!answer) return '';
  let normalized = answer.trim();
  if (type === 'fill-latin') {
    normalized = normalized.toLowerCase();
  }
  if (type === 'fill-arab') {
    normalized = normalized
      .replace(/[ً-ْ]/g, '')
      .replace(/[ـ]/g, '');
  }
  return normalized;
}

function setAnswer(questionId, answer) {
  const state = window._quizState;
  if (!state || state.submitted) return;
  state.selectedAnswers[questionId] = answer;
}

function getSelectedAnswers() {
  const state = window._quizState;
  return state ? { ...state.selectedAnswers } : {};
}

function resetQuiz(bank) {
  const state = window._quizState;
  if (!state || !bank) return;
  const questions = shuffleQuiz(bank);
  state.questions = questions;
  state.selectedAnswers = {};
  state.submitted = false;
  return questions;
}

// ================================================================
// RENDER (DOM manipulation)
// ================================================================

function renderQuestion() {
  const dbg = document.getElementById('quizDebug');
  function log(msg) {
    if (dbg) { dbg.style.display = 'block'; dbg.textContent += '[RQ] ' + msg + '\n'; dbg.scrollTop = dbg.scrollHeight; }
    console.log('[RQ]', msg);
  }

  log('renderQuestion called, _quizState: ' + (window._quizState ? 'EXISTS' : 'NULL'));

  const state = window._quizState;
  const container = document.getElementById('quizContent');
  if (!container) { log('ERROR: quizContent not found!'); return; }

  const answers = state ? (state.selectedAnswers || {}) : {};
  const total = state ? state.questions.length : 0;
  const idx = total > 0 ? Math.min(currentQuestionIndex, total - 1) : 0;

  log('total=' + total + ', idx=' + idx);

  // Update progress header
  document.getElementById('currentQ').textContent = total > 0 ? (idx + 1) : 1;
  document.getElementById('totalQ').textContent = total > 0 ? total : 10;
  const pct = total > 0 ? Math.round(((idx + 1) / total) * 100) : 0;
  document.getElementById('progressPercent').textContent = pct + '%';
  document.getElementById('progressBar').style.width = (total > 0 ? Math.max(pct, 2) : 2) + '%';

  // Update dots
  const dotsEl = document.getElementById('questionDots');
  dotsEl.innerHTML = '';
  if (state && state.questions) {
    state.questions.forEach(function(qi, i) {
      const isAnswered = !!answers[qi.id];
      const isCurrent = i === idx;
      const isCorrect = answeredQuestions[qi.id] === true;
      const isWrong = answeredQuestions[qi.id] === false;
      let dotClass = 'progress-dot';
      if (isCurrent) dotClass += ' current';
      else if (isCorrect) dotClass += ' correct';
      else if (isWrong) dotClass += ' wrong';
      else if (isAnswered) dotClass += ' answered';
      const btn = document.createElement('button');
      btn.className = dotClass;
      btn.title = 'Soal ' + (i + 1);
      btn.style.cssText = 'background:none;border:none;cursor:pointer;padding:0;';
      btn.onclick = (function(ii) { return function() { goToQuestion(ii); }; })(i);
      dotsEl.appendChild(btn);
    });
  }

  // Preserve debug div
  const debugDiv = document.getElementById('quizDebug');
  container.innerHTML = '';
  if (debugDiv) container.appendChild(debugDiv);

  // Guard
  if (!state || !state.questions || state.questions.length === 0) {
    log('GUARD: no state or no questions');
    const guardDiv = document.createElement('div');
    guardDiv.className = 'text-center';
    guardDiv.style.cssText = 'display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:200px;color:#ef4444;';
    guardDiv.innerHTML = '<i class="fa-solid fa-exclamation-triangle" style="font-size:2rem;margin-bottom:8px;"></i><p>Quiz tidak tersedia.</p>';
    container.appendChild(guardDiv);
    return;
  }

  const q = state.questions[idx];
  log('q=' + (q ? q.id + ' type=' + q.type + ' text=' + (q.question || '').substring(0, 50) : 'NULL'));

  if (!q || !q.id) {
    const invalidDiv = document.createElement('div');
    invalidDiv.className = 'text-center py-8';
    invalidDiv.style.cssText = 'color:#94a3b8;';
    invalidDiv.innerHTML = '<i class="fa-solid fa-circle-exclamation" style="font-size:2rem;margin-bottom:8px;display:block;"></i><p>Data soal tidak valid.</p>';
    container.appendChild(invalidDiv);
    return;
  }

  // Type badge
  const badge = document.createElement('span');
  badge.className = 'quiz-question-type' + (q.type === 'mc' ? ' mc' : q.type === 'fill-arab' ? ' arab' : ' latin');
  if (q.type === 'mc') {
    badge.innerHTML = '<i class="fa-solid fa-list-check"></i> Pilihan Ganda';
  } else if (q.type === 'fill-arab') {
    badge.innerHTML = '<i class="fa-solid fa-pen"></i> Isi Arab';
  } else {
    badge.innerHTML = '<i class="fa-solid fa-pen"></i> Isi Latin';
  }
  container.appendChild(badge);

  // Question box
  const qBox = document.createElement('div');
  qBox.className = 'quiz-question-box';
  const qText = q.question || '';
  if (!qText.trim()) {
    qBox.classList.add('quiz-no-content');
    qBox.innerHTML = '<i class="fa-solid fa-circle-info" style="color:#94a3b8;font-size:1.5rem;margin-bottom:8px;display:block;"></i><p style="color:#94a3b8;font-size:0.9rem;">Pertanyaan ini belum memiliki teks.</p>';
  } else {
    const qP = document.createElement('p');
    qP.className = 'quiz-question-text';
    qP.textContent = qText;
    qBox.appendChild(qP);
  }
  container.appendChild(qBox);

  // Options / Fill input
  if (q.type === 'mc' && q.options) {
    let optsObj = {};
    try {
      const parsed = JSON.parse(q.options);
      if (Array.isArray(parsed)) {
        parsed.forEach(function(item) { optsObj[item.key] = item.value; });
      } else {
        optsObj = parsed;
      }
    } catch (e) { log('JSON.parse error: ' + e.message); }

    log('optsObj keys: ' + Object.keys(optsObj).join(', '));
    const optsDiv = document.createElement('div');
    optsDiv.className = 'quiz-options';
    Object.keys(optsObj).forEach(function(key) {
      const isSelected = answers[q.id] === key;
      const optDiv = document.createElement('div');
      optDiv.className = 'quiz-option' + (isSelected ? ' selected' : '');
      optDiv.style.cssText = 'display:flex;align-items:center;gap:12px;padding:12px 16px;margin-bottom:8px;border-radius:12px;border:2px solid #e2e8f0;cursor:pointer;transition:all 0.2s;background:#fff;';
      optDiv.onmouseover = function() { if (!isSelected) optDiv.style.borderColor = '#10b981'; };
      optDiv.onmouseout = function() { if (!isSelected) optDiv.style.borderColor = '#e2e8f0'; };
      optDiv.onclick = (function(qid, k) { return function() { window.selectAnswer(qid, k); }; })(q.id, key);

      const keyDiv = document.createElement('div');
      keyDiv.className = 'quiz-option-key';
      keyDiv.style.cssText = 'width:28px;height:28px;border-radius:50%;background:#f1f5f9;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:0.85rem;color:#475569;flex-shrink:0;';
      keyDiv.textContent = key;

      const txtDiv = document.createElement('div');
      txtDiv.className = 'quiz-option-text';
      txtDiv.style.cssText = 'flex:1;font-size:0.95rem;color:#334155;';
      txtDiv.textContent = optsObj[key];

      const chkDiv = document.createElement('div');
      chkDiv.className = 'quiz-option-check';
      chkDiv.style.cssText = 'color:#10b981;opacity:' + (isSelected ? '1' : '0') + ';transition:opacity 0.2s;';
      chkDiv.innerHTML = '<i class="fa-solid fa-check text-xs"></i>';

      optDiv.appendChild(keyDiv);
      optDiv.appendChild(txtDiv);
      optDiv.appendChild(chkDiv);
      optsDiv.appendChild(optDiv);
    });
    container.appendChild(optsDiv);
  } else {
    const inp = document.createElement('input');
    inp.type = 'text';
    inp.id = 'answerInput';
    inp.value = answers[q.id] || '';
    inp.placeholder = 'Ketik jawaban...';
    inp.className = 'quiz-fill-input';
    inp.style.cssText = 'width:100%;padding:12px 16px;border-radius:12px;border:2px solid #e2e8f0;font-size:0.95rem;outline:none;box-sizing:border-box;';
    inp.oninput = (function(qid) { return function() { setAnswer(qid, inp.value); }; })(q.id);
    container.appendChild(inp);
  }

  // Navigation buttons
  const navDiv = document.createElement('div');
  navDiv.className = 'quiz-nav';

  const backBtn = document.createElement('button');
  backBtn.className = 'btn btn-secondary' + (currentQuestionIndex === 0 ? ' opacity-50' : '');
  backBtn.disabled = currentQuestionIndex === 0;
  backBtn.innerHTML = '<i class="fa-solid fa-arrow-left"></i> Kembali';
  if (currentQuestionIndex > 0) backBtn.onclick = window.prevQuestion;
  navDiv.appendChild(backBtn);

  const actionBtn = document.createElement('button');
  actionBtn.className = 'btn btn-primary';
  if (currentQuestionIndex < total - 1) {
    actionBtn.innerHTML = 'Lanjut <i class="fa-solid fa-arrow-right"></i>';
    actionBtn.onclick = window.nextQuestion;
  } else {
    actionBtn.innerHTML = '<i class="fa-solid fa-check"></i> Kirim';
    actionBtn.onclick = window.submitQuestion;
  }
  navDiv.appendChild(actionBtn);

  container.appendChild(navDiv);
  log('DONE, childElementCount=' + container.childElementCount);
}

function prevQuestion() {
  if (currentQuestionIndex > 0) {
    currentQuestionIndex--;
    renderQuestion();
  }
}

function nextQuestion() {
  if (currentQuestionIndex < quizQuestions.length - 1) {
    currentQuestionIndex++;
    renderQuestion();
  }
}

function goToQuestion(index) {
  currentQuestionIndex = index;
  renderQuestion();
}

function selectAnswer(qid, ans) {
  setAnswer(qid, ans);
  answeredQuestions[qid] = null;
  renderQuestion();
}

function submitQuestion() {
  const result = window.submitQuizResult();
  if (!result) return;

  const state = window._quizState;
  state.questions.forEach(function(q) {
    if (result.results) {
      const qResult = result.results.find(function(r) { return r.questionId === q.id; });
      if (qResult) {
        answeredQuestions[q.id] = qResult.isCorrect;
      }
    }
  });

  const container = document.getElementById('quizContent');

  const icon = result.passed ? 'fa-check-circle' : 'fa-times-circle';
  const iconClass = result.passed ? 'text-green-500' : 'text-red-500';
  const bgClass = result.passed ? 'from-green-50 to-emerald-50' : 'from-red-50 to-orange-50';
  const title = result.passed ? 'Alhamdulillah!' : 'Belum Lulus';
  const titleClass = result.passed ? 'text-green-600' : 'text-red-600';
  const msg = result.passed ? 'Semua jawabanmu benar!' : 'Skor: ' + result.score + '%. Syarat: 100%.';

  container.innerHTML = '<div class="text-center py-12 bg-gradient-to-b ' + bgClass + ' rounded-2xl">';
  container.innerHTML += '<div class="w-24 h-24 bg-white rounded-full flex items-center justify-center mx-auto mb-6 shadow-xl">';
  container.innerHTML += '<i class="fa-solid ' + icon + ' ' + iconClass + ' text-5xl"></i>';
  container.innerHTML += '</div>';
  container.innerHTML += '<h3 class="text-3xl font-bold ' + titleClass + ' mb-3">' + title + '</h3>';
  container.innerHTML += '<p class="text-slate-600 mb-6">' + msg + '</p>';
  container.innerHTML += '<div class="inline-flex items-center gap-4 bg-white px-6 py-3 rounded-2xl shadow-lg mb-6">';
  container.innerHTML += '<div class="text-center"><div class="text-3xl font-bold ' + (result.passed ? 'text-green-500' : 'text-red-500') + '">' + result.score + '%</div><div class="text-xs text-slate-500">Skor</div></div>';
  container.innerHTML += '<div class="w-px h-10 bg-slate-200"></div>';
  container.innerHTML += '<div class="text-center"><div class="text-3xl font-bold text-dark-800">' + result.correct + '/' + result.total + '</div><div class="text-xs text-slate-500">Benar</div></div>';
  container.innerHTML += '</div>';

  if (result.passed) {
    container.innerHTML += '<a href="student.html" class="btn btn-primary"><i class="fa-solid fa-home"></i> Kembali ke Dashboard</a>';
  } else {
    container.innerHTML += '<div class="flex flex-wrap justify-center gap-3">';
    container.innerHTML += '<button onclick="window.retryQuiz()" class="btn btn-primary"><i class="fa-solid fa-redo"></i> Coba Lagi</button>';
    container.innerHTML += '<button onclick="window.closeQuiz()" class="btn btn-secondary"><i class="fa-solid fa-arrow-left"></i> Kembali</button>';
    container.innerHTML += '</div>';
  }
  container.innerHTML += '</div>';
}

// ================================================================
// START / RETRY / CLOSE
// ================================================================

function retryQuiz() {
  if (quizBankLoaded.length === 0) quizBankLoaded = quizBank;
  resetQuiz(quizBankLoaded);
  quizQuestions = window._quizState.questions;
  currentQuestionIndex = 0;
  answeredQuestions = {};
  renderQuestion();
}

function closeQuiz() {
  document.getElementById('quizModal').classList.add('hidden');
  document.body.style.overflow = '';
  window.location.href = 'student.html';
}

function startQuiz() {
  console.log('[QUIZ] startQuiz called, quizBank.length=' + quizBank.length);

  if (quizBank.length === 0) {
    alert('Quiz bank kosong!');
    return;
  }

  document.getElementById('quizModal').classList.remove('hidden');
  document.body.style.overflow = 'hidden';

  const quizId = currentFasal ? currentFasal.id : currentBab.id;
  const quizTitle = currentFasal ? currentFasal.title : currentBab.title;
  document.getElementById('quizFasalName').textContent = quizTitle;

  initQuiz(quizBank, quizId, 10, {
    onPass: function(score, correct, total, results) {
      handleQuizComplete(true, score, correct, total);
    },
    onFail: function(score, correct, total, results) {
      handleQuizComplete(false, score, correct, total);
    }
  });

  quizBankLoaded = quizBank;
  quizQuestions = window._quizState.questions;
  currentQuestionIndex = 0;
  answeredQuestions = {};
  document.getElementById('totalQ').textContent = quizQuestions.length;

  renderQuestion();
}

// Expose all functions on window
window.startQuiz = startQuiz;
window.closeQuiz = closeQuiz;
window.retryQuiz = retryQuiz;
window.prevQuestion = prevQuestion;
window.nextQuestion = nextQuestion;
window.goToQuestion = goToQuestion;
window.selectAnswer = selectAnswer;
window.submitQuestion = submitQuestion;
window.renderQuestion = renderQuestion;

// Dummy handleQuizComplete (actual implementation in materi.html)
function handleQuizComplete(passed, score, correct, total) {
  console.log('[QUIZ] Quiz complete:', passed ? 'PASSED' : 'FAILED', score + '%');
}

// ================================================================
// SUPABASE INTEGRATION
// ================================================================

async function saveProgress(fasalId, score, attempts, status) {
  const token = getToken();
  if (!token) return;

  const user = await getCurrentUser();
  if (!user) return;

  const body = {
    user_id: user.id,
    fasal_id: fasalId,
    quiz_score: score,
    quiz_attempts: attempts,
    status,
    completed_at: status === 'completed' ? new Date().toISOString() : null,
  };

  let existing = null;
  try {
    existing = await fetchFasalProgress(fasalId);
  } catch (e) {}

  if (existing) {
    await fetch(
      `${SUPABASE_URL}rest/v1/user_progress?id=eq.${existing.id}`,
      {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'apikey': SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${token}`,
          'Prefer': 'return=minimal',
        },
        body: JSON.stringify(body),
      }
    );
  } else {
    const postBody = { ...body, started_at: new Date().toISOString() };
    await fetch(`${SUPABASE_URL}rest/v1/user_progress`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${token}`,
        'Prefer': 'return=representation',
      },
      body: JSON.stringify(postBody),
    });
  }
}

async function fetchFasalProgress(fasalId) {
  const token = getToken();
  if (!token) return null;
  const user = await getCurrentUser();
  if (!user) return null;
  const encodedFasalId = encodeURIComponent(fasalId);
  const res = await fetch(
    `${SUPABASE_URL}rest/v1/user_progress?user_id=eq.${user.id}&fasal_id=eq.${encodedFasalId}&select=*`,
    {
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${token}`,
      },
    }
  );
  if (!res.ok) return null;
  const data = await res.json();
  return data[0] || null;
}

async function fetchBabProgress(babId) {
  const token = getToken();
  if (!token) return null;
  const user = await getCurrentUser();
  if (!user) return null;
  const encodedBabId = encodeURIComponent(babId);
  const res = await fetch(
    `${SUPABASE_URL}rest/v1/user_progress?user_id=eq.${user.id}&fasal_id=eq.${encodedBabId}&select=*`,
    {
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${token}`,
      },
    }
  );
  if (!res.ok) return null;
  const data = await res.json();
  return data[0] || null;
}

async function fetchQuizBankBab(babId) {
  const token = getToken();
  const headers = {
    'apikey': SUPABASE_ANON_KEY,
    ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
  };
  try {
    const res = await fetch(
      `${SUPABASE_URL}rest/v1/quiz?bab_id=eq.${babId}&order=order_index`,
      { headers }
    );
    if (!res.ok) return [];
    return res.json();
  } catch (err) {
    return [];
  }
}

async function fetchQuizBank(fasalId) {
  const token = getToken();
  const headers = {
    'apikey': SUPABASE_ANON_KEY,
    ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
  };
  try {
    const res = await fetch(
      `${SUPABASE_URL}rest/v1/quiz?fasal_id=eq.${fasalId}&order=order_index`,
      { headers }
    );
    if (!res.ok) return [];
    return res.json();
  } catch (err) {
    return [];
  }
}

async function fetchFasal(fasalId) {
  const token = getToken();
  const headers = {
    'apikey': SUPABASE_ANON_KEY,
    ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
  };
  const res = await fetch(
    `${SUPABASE_URL}rest/v1/fasal?id=eq.${fasalId}&select=*,bab(*,bagian(*))`,
    { headers }
  );
  if (!res.ok) return null;
  const data = await res.json();
  return data[0] || null;
}
