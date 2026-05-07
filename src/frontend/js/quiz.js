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

/**
 * Ambil N soal secara random dari bank
 * @param {Array}  bank    — semua soal dari Supabase/API
 * @param {number} count   — jumlah soal yang diambil (default: DEFAULT_QUESTIONS)
 * @returns {Array}        — array soal yang sudah diacak
 */
function shuffleQuiz(bank, count = DEFAULT_QUESTIONS) {
  const shuffled = [...bank].sort(() => Math.random() - 0.5);
  return shuffled.slice(0, Math.min(count, bank.length));
}

/**
 * Initialize quiz — ambil soal acak + render
 * @param {Array}  bank      — array semua soal dari bank
 * @param {string} fasalId   — ID fasal aktif
 * @param {number} count     — jumlah soal (default dari fasal.quiz_count atau 10)
 * @param {Object} callbacks — { onPass(score, answers), onFail(score, answers) }
 */
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

/**
 * Submit jawaban quiz — hitung skor + pass/fail
 * @returns {Object} { score, passed, results: [{questionId, correct, userAnswer, correctAnswer}] }
 */
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

// Export for use in other scripts
window.submitQuizResult = submitQuiz;

/**
 * Normalize jawaban untuk perbandingan
 * - Hilangkan spasi berlebihan
 * - Lowercase untuk fill-latin
 * - Normalize Arabic diacritics untuk fill-arab
 * @param {string} answer
 * @param {string} type
 * @returns {string}
 */
function normalizeAnswer(answer, type) {
  if (!answer) return '';
  let normalized = answer.trim();
  if (type === 'fill-latin') {
    normalized = normalized.toLowerCase();
  }
  if (type === 'fill-arab') {
    // Normalize Arabic: hapus semua fatha, kasrah, dhammah, sukun, tanwin
    normalized = normalized
      .replace(/[ً-ْ]/g, '') // harakat
      .replace(/[ـ]/g, ''); // tatwil/shadda
  }
  return normalized;
}

/**
 * Set jawaban untuk satu soal
 * @param {string} questionId
 * @param {string} answer
 */
function setAnswer(questionId, answer) {
  const state = window._quizState;
  if (!state || state.submitted) return;
  state.selectedAnswers[questionId] = answer;
}

/**
 * Ambil semua jawaban student
 * @returns {Object}
 */
function getSelectedAnswers() {
  const state = window._quizState;
  return state ? { ...state.selectedAnswers } : {};
}

/**
 * Reset quiz — acak ulang soal baru
 */
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
// SUPABASE INTEGRATION (untuk production)
// ================================================================

/**
 * Fetch bank soal dari Supabase
 * @param {string} fasalId
 * @returns {Promise<Array>}
 */
async function fetchQuizBank(fasalId) {
  const token = getToken();
  const headers = {
    'apikey': SUPABASE_ANON_KEY,
    ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
  };
  const res = await fetch(`${SUPABASE_URL}rest/v1/quiz?fasal_id=eq.${fasalId}&order=order_index`, { headers });
  if (!res.ok) throw new Error('Gagal mengambil bank soal');
  return res.json();
}

/**
 * Simpan hasil kuis ke Supabase
 * @param {string} fasalId
 * @param {number} score
 * @param {number} attempts
 */
async function saveQuizResult(fasalId, score, attempts = 1) {
  // TODO: implement with Supabase JS SDK
  // const { data, error } = await supabase
  //   .from('user_progress')
  //   .upsert({ ... });
}
