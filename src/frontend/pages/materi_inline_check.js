
    // XSS protection - escape HTML special characters
    function escapeHtml(text) {
      if (!text) return '';
      var div = document.createElement('div');
      div.textContent = text;
      return div.innerHTML;
    }

    var currentFasal = null;
    var currentBab = null;
    var quizBank = [];

    var urlParams = new URLSearchParams(window.location.search);
    var fasalId = urlParams.get('id');
    var babId = urlParams.get('bab');

    (async function() {
      var user = await getCurrentUser();
      if (!user) {
        window.location.href = 'auth.html';
        return;
      }
      var role = (user.user_metadata && user.user_metadata.role) || 'student';
      if (role === 'admin' || role === 'teacher') {
        document.getElementById('adminLinkMateri').classList.remove('hidden');
      }
      if (babId) {
        await loadBab(babId);
      } else if (fasalId) {
        await loadFasal(fasalId);
      } else {
        window.location.href = 'student.html';
      }
    })();

    async function loadBab(babId) {
      try {
        var res = await fetch(SUPABASE_URL + 'rest/v1/bab?id=eq.' + babId + '&select=*,bagian(*)', {
          headers: { 'apikey': SUPABASE_ANON_KEY, 'Authorization': 'Bearer ' + getToken() }
        });
        var data = await res.json();
        console.log('loadBab: response status', res.status, 'data:', data);
        var bab = data[0];

        if (!bab) {
          console.log('loadBab: bab not found in response');
          window.location.href = 'student.html';
          return;
        }

        currentBab = bab;

        document.getElementById('breadcrumbKitab').textContent = 'Kitab Mukhtarat';
        document.getElementById('breadcrumbBagian').textContent = 'Bagian ' + (bab.bagian ? bab.bagian.order_index : 1);
        document.getElementById('breadcrumbBab').textContent = 'Bab ' + bab.order_index;
        document.getElementById('breadcrumbFasal').textContent = bab.title || 'Muqoddimah';

        document.getElementById('fasalTitle').textContent = bab.title || 'Muqoddimah';
        document.getElementById('fasalNumber').textContent = (bab.bagian ? bab.bagian.order_index : 1) + '.' + bab.order_index;
        document.getElementById('fasalType').textContent = 'MUQODDIMAH';
        document.getElementById('fasalType').className = 'badge badge-amber';
        document.getElementById('fasalBab').textContent = 'Bab ' + bab.order_index + ' dari Bagian ' + (bab.bagian ? bab.bagian.order_index : 1);
        document.getElementById('quizFasalName').textContent = 'Tes Muqoddimah';

        var content = bab.content_arab && bab.content_arab.trim()
          ? bab.content_arab
          : '<div style="text-align:center; padding:48px 24px; background:#fef3c7; border-radius:16px; border:1px solid #fcd34d; margin:8px 0;"><i class="fa-solid fa-file-import" style="font-size:2rem; color:#d97706; margin-bottom:12px; display:block;"></i><p style="font-size:1rem; font-weight:600; color:#92400e; margin-bottom:4px;">Konten belum tersedia</p><p style="font-size:0.8rem; color:#b45309;">Admin perlu menambahkan materi Arab terlebih dahulu.</p></div>';
        document.getElementById('fasalContent').innerHTML = content;

        if (bab.content_id) {
          document.getElementById('translationSection').classList.remove('hidden');
          document.getElementById('fasalTranslation').innerHTML = bab.content_id;
        }

        var progress = null;
        try { progress = await fetchBabProgress(babId); } catch (e) {}
        updateStatus(progress);

        quizBank = [];
        try {
          quizBank = await fetchQuizBankBab(babId);
          console.log('loadBab: fetchQuizBankBab returned', quizBank.length, 'quizzes', quizBank);
          if (quizBank.length === 0 && currentBab) {
            var fasalRes = await fetch(SUPABASE_URL + 'rest/v1/fasal?bab_id=eq.' + babId + '&select=id', { headers: { 'apikey': SUPABASE_ANON_KEY, 'Authorization': 'Bearer ' + getToken() } });
            var fasals = await fasalRes.json();
            console.log('loadBab: fasals under bab:', fasals);
            for (var f of fasals) {
              var fQuizzes = await fetchQuizBank(f.id);
              console.log('loadBab: fetchQuizBank for fasal', f.id, 'returned', fQuizzes.length, 'quizzes');
              quizBank = quizBank.concat(fQuizzes);
            }
          }
        } catch (e) { console.error('loadBab: quiz fetch error', e); }

        if (quizBank.length === 0) {
          document.getElementById('startQuizBtn').disabled = true;
          document.getElementById('startQuizBtn').classList.add('opacity-50', 'cursor-not-allowed');
          document.getElementById('startQuizBtn').innerHTML = '<i class="fa-solid fa-lock"></i> Belum Ada Quiz';
        }

      } catch (err) {
        document.getElementById('fasalContent').innerHTML = '<div class="text-center py-12 text-red-500"><i class="fa-solid fa-exclamation-triangle mr-2"></i> Gagal memuat: ' + err.message + '</div>';
      }
    }

    async function loadFasal(fasalId) {
      try {
        var fasal = await fetchFasal(fasalId);
        if (!fasal) {
          window.location.href = 'student.html';
          return;
        }

        currentFasal = fasal;

        // Fetch audio URL
        try {
          var audioRes = await fetch(SUPABASE_URL + 'rest/v1/fasal?id=eq.' + fasalId + '&select=audio_url', {
            headers: { 'apikey': SUPABASE_ANON_KEY, 'Authorization': 'Bearer ' + getToken() }
          });
          var audioData = await audioRes.json();
          if (audioData.length > 0) {
            currentFasal.audio_url = audioData[0].audio_url;
          }
        } catch (e) {}

        var bagianOrder = 1;
        var babOrder = 1;
        var babTitle = 'Bab';

        if (fasal.bab) {
          var bab = fasal.bab;
          babOrder = bab.order_index;
          babTitle = bab.title || bab.nama || 'Bab ' + bab.order_index;
          if (bab.bagian) {
            bagianOrder = bab.bagian.order_index;
          }
        }

        document.getElementById('breadcrumbKitab').textContent = 'Kitab Mukhtarat';
        document.getElementById('breadcrumbBagian').textContent = 'Bagian ' + bagianOrder;
        document.getElementById('breadcrumbBab').textContent = 'Bab ' + babOrder;
        document.getElementById('breadcrumbFasal').textContent = fasal.title || 'Fasal';

        document.getElementById('fasalTitle').textContent = fasal.title || 'Fasal';
        document.getElementById('fasalNumber').textContent = bagianOrder + '.' + babOrder + '.' + fasal.order_index;
        document.getElementById('fasalType').textContent = 'FASAL';
        document.getElementById('fasalType').className = 'badge badge-blue';
        document.getElementById('fasalBab').textContent = babTitle + ' dari Bagian ' + bagianOrder;
        document.getElementById('quizFasalName').textContent = 'Tes ' + (fasal.title || 'Fasal');

        var content = fasal.content_arab && fasal.content_arab.trim()
          ? fasal.content_arab
          : '<div style="text-align:center; padding:48px 24px; background:#fef3c7; border-radius:16px; border:1px solid #fcd34d; margin:8px 0;"><i class="fa-solid fa-file-import" style="font-size:2rem; color:#d97706; margin-bottom:12px; display:block;"></i><p style="font-size:1rem; font-weight:600; color:#92400e; margin-bottom:4px;">Konten belum tersedia</p><p style="font-size:0.8rem; color:#b45309;">Admin perlu menambahkan materi Arab terlebih dahulu.</p></div>';
        document.getElementById('fasalContent').innerHTML = content;

        if (fasal.content_id) {
          document.getElementById('translationSection').classList.remove('hidden');
          document.getElementById('fasalTranslation').innerHTML = fasal.content_id;
        }

        var progress = null;
        try { progress = await fetchFasalProgress(fasalId); } catch (e) {}
        updateStatus(progress);

        quizBank = [];
        try { quizBank = await fetchQuizBank(fasalId); } catch (e) {}

        if (quizBank.length === 0) {
          document.getElementById('startQuizBtn').disabled = true;
          document.getElementById('startQuizBtn').classList.add('opacity-50', 'cursor-not-allowed');
          document.getElementById('startQuizBtn').innerHTML = '<i class="fa-solid fa-lock"></i> Belum Ada Quiz';
        }

      } catch (err) {
        document.getElementById('fasalContent').innerHTML = '<div class="text-center py-12 text-red-500"><i class="fa-solid fa-exclamation-triangle mr-2"></i> Gagal memuat: ' + err.message + '</div>';
      }
    }

    function updateStatus(progress) {
      var statusEl = document.getElementById('fasalStatus');
      if (!progress) {
        statusEl.className = 'header-status';
        statusEl.innerHTML = '<i class="fa-regular fa-circle"></i><span>Belum Dimulai</span>';
      } else if (progress.status === 'completed') {
        statusEl.className = 'header-status badge badge-success';
        statusEl.innerHTML = '<i class="fa-solid fa-check"></i><span>Lulus (' + progress.quiz_score + '%)</span>';
      } else if (progress.status === 'unlocked') {
        statusEl.className = 'header-status badge badge-amber';
        statusEl.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i><span>Sedang Dikerjakan</span>';
      } else {
        statusEl.className = 'header-status';
        statusEl.innerHTML = '<i class="fa-regular fa-circle"></i><span>Belum Dimulai</span>';
      }
    }

    var quizQuestions = [];
    var currentQuestionIndex = 0;
    var selectedAnswers = {};
    var quizBankLoaded = [];
    var answeredQuestions = {};

    function startQuiz() {
      console.log('startQuiz: quizBank.length =', quizBank.length, 'quizBank[0] =', JSON.stringify(quizBank[0]));
      if (quizBank.length === 0) {
        alert('Quiz bank kosong! Pastikan bab ini punya quiz di database.\n\nBuka DevTools (F12) &rarr; Console untuk info debug.');
        return;
      }
      document.getElementById('quizModal').classList.remove('hidden');
      document.body.style.overflow = 'hidden';

      var quizId = currentFasal ? currentFasal.id : currentBab.id;
      var quizTitle = currentFasal ? currentFasal.title : currentBab.title;
      document.getElementById('quizFasalName').textContent = quizTitle;

      var shuffled = initQuiz(quizBank, quizId, 10, {
        onPass: function(score, correct, total, results) { handleQuizComplete(true, score, correct, total); },
        onFail: function(score, correct, total, results) { handleQuizComplete(false, score, correct, total); }
      });

      quizBankLoaded = quizBank;
      quizQuestions = window._quizState.questions;
      currentQuestionIndex = 0;
      selectedAnswers = {};
      answeredQuestions = {};
      document.getElementById('totalQ').textContent = quizQuestions.length;

      console.log('startQuiz: _quizState.questions.length =', window._quizState.questions.length, 'currentQuestionIndex =', currentQuestionIndex);
      renderQuestion();
    }

    function renderQuestion() {
      var state = window._quizState;
      var container = document.getElementById('quizContent');
      console.log('--- renderQuestion() ---');
      console.log('window._quizState:', state);
      console.log('currentQuestionIndex:', currentQuestionIndex);
      console.log('quizContent element:', container);
      console.log('quizContent.innerHTML BEFORE:', container.innerHTML);
      var answers = state ? (state.selectedAnswers || {}) : {};
      var total = state ? state.questions.length : 0;
      var idx = total > 0 ? Math.min(currentQuestionIndex, total - 1) : 0;
      console.log('total questions:', total, '| idx used:', idx);
      document.getElementById('currentQ').textContent = total > 0 ? (idx + 1) : 1;
      document.getElementById('totalQ').textContent = total > 0 ? total : 10;
      var pct = total > 0 ? Math.round(((idx + 1) / total) * 100) : 0;
      document.getElementById('progressPercent').textContent = pct + '%';
      document.getElementById('progressBar').style.width = (total > 0 ? Math.max(pct, 2) : 2) + '%';

      // --- Update dots ---
      var dotsEl = document.getElementById('questionDots');
      dotsEl.innerHTML = '';
      if (state && state.questions) {
        state.questions.forEach(function(qi, i) {
          var isAnswered = !!answers[qi.id];
          var isCurrent = i === idx;
          var isCorrect = answeredQuestions[qi.id] === true;
          var isWrong = answeredQuestions[qi.id] === false;
          var dotClass = 'progress-dot';
          if (isCurrent) dotClass += ' current';
          else if (isCorrect) dotClass += ' correct';
          else if (isWrong) dotClass += ' wrong';
          else if (isAnswered) dotClass += ' answered';
          var btn = document.createElement('button');
          btn.className = dotClass;
          btn.title = 'Soal ' + (i + 1);
          btn.style.cssText = 'background:none;border:none;cursor:pointer;padding:0;';
          btn.onclick = (function(ii) { return function() { goToQuestion(ii); }; })(i);
          dotsEl.appendChild(btn);
        });
      }

      // --- Clear container ---
      container.innerHTML = '';

      // --- Guard: no state ---
      if (!state || !state.questions || state.questions.length === 0) {
        console.log('renderQuestion: GUARD triggered - no state or no questions');
        container.style.cssText = 'display:flex;align-items:center;justify-content:center;min-height:200px;';
        container.innerHTML = '<div class="text-center" style="color:#ef4444;">' +
          '<i class="fa-solid fa-exclamation-triangle" style="font-size:2rem;margin-bottom:8px;display:block;"></i>' +
          '<p>Quiz tidak tersedia.</p>' +
          '<p style="font-size:0.8rem;color:#888;margin-top:4px;">Buka DevTools &rarr; Console untuk detail.</p></div>';
        console.log('quizContent.innerHTML AFTER guard:', container.innerHTML);
        return;
      }

      var q = state.questions[idx];
      console.log('renderQuestion: q =', q);
      if (!q || !q.id) {
        container.innerHTML = '<div class="text-center py-8" style="color:#94a3b8;"><i class="fa-solid fa-circle-exclamation" style="font-size:2rem;margin-bottom:8px;display:block;"></i><p>Data soal tidak valid.</p></div>';
        return;
      }

      // --- Type badge ---
      var badge = document.createElement('span');
      badge.className = 'quiz-question-type' + (q.type === 'mc' ? ' mc' : q.type === 'fill-arab' ? ' arab' : ' latin');
      if (q.type === 'mc') {
        badge.innerHTML = '<i class="fa-solid fa-list-check"></i> Pilihan Ganda';
      } else if (q.type === 'fill-arab') {
        badge.innerHTML = '<i class="fa-solid fa-pen"></i> Isi Arab';
      } else {
        badge.innerHTML = '<i class="fa-solid fa-pen"></i> Isi Latin';
      }
      container.appendChild(badge);

      // --- Question box ---
      var qBox = document.createElement('div');
      qBox.className = 'quiz-question-box';
      var qText = q.question || '';
      if (!qText.trim()) {
        qBox.classList.add('quiz-no-content');
        qBox.innerHTML = '<i class="fa-solid fa-circle-info" style="color:#94a3b8;font-size:1.5rem;margin-bottom:8px;display:block;"></i>' +
          '<p style="color:#94a3b8;font-size:0.9rem;">Pertanyaan ini belum memiliki teks.</p>';
      } else {
        var qP = document.createElement('p');
        qP.className = 'quiz-question-text';
        qP.textContent = qText;
        qBox.appendChild(qP);
      }
      container.appendChild(qBox);

      // --- Options / Fill input ---
      if (q.type === 'mc' && q.options) {
        var optsObj = {};
        try {
          var parsed = JSON.parse(q.options);
          if (Array.isArray(parsed)) {
            parsed.forEach(function(item) { optsObj[item.key] = item.value; });
          } else {
            optsObj = parsed;
          }
        } catch (e) {}

        var optsDiv = document.createElement('div');
        optsDiv.className = 'quiz-options';
        Object.keys(optsObj).forEach(function(key) {
          var isSelected = answers[q.id] === key;
          var optDiv = document.createElement('div');
          optDiv.className = 'quiz-option' + (isSelected ? ' selected' : '');
          optDiv.style.cssText = 'display:flex;align-items:center;gap:12px;padding:12px 16px;margin-bottom:8px;border-radius:12px;border:2px solid #e2e8f0;cursor:pointer;transition:all 0.2s;background:#fff;';
          optDiv.onmouseover = function() { if (!isSelected) optDiv.style.borderColor = '#10b981'; };
          optDiv.onmouseout = function() { if (!isSelected) optDiv.style.borderColor = '#e2e8f0'; };
          optDiv.onclick = (function(qid, k) { return function() { selectAnswer(qid, k); }; })(q.id, key);

          var keyDiv = document.createElement('div');
          keyDiv.className = 'quiz-option-key';
          keyDiv.style.cssText = 'width:28px;height:28px;border-radius:50%;background:#f1f5f9;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:0.85rem;color:#475569;flex-shrink:0;';
          keyDiv.textContent = key;

          var txtDiv = document.createElement('div');
          txtDiv.className = 'quiz-option-text';
          txtDiv.style.cssText = 'flex:1;font-size:0.95rem;color:#334155;';
          txtDiv.textContent = optsObj[key];

          var chkDiv = document.createElement('div');
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
        var inp = document.createElement('input');
        inp.type = 'text';
        inp.id = 'answerInput';
        inp.value = answers[q.id] || '';
        inp.placeholder = 'Ketik jawaban...';
        inp.className = 'quiz-fill-input';
        inp.style.cssText = 'width:100%;padding:12px 16px;border-radius:12px;border:2px solid #e2e8f0;font-size:0.95rem;outline:none;box-sizing:border-box;';
        inp.oninput = (function(qid) { return function() { setAnswer(qid, inp.value); }; })(q.id);
        container.appendChild(inp);
      }

      // --- Navigation buttons ---
      var navDiv = document.createElement('div');
      navDiv.className = 'quiz-nav';

      var backBtn = document.createElement('button');
      backBtn.className = 'btn btn-secondary' + (currentQuestionIndex === 0 ? ' opacity-50' : '');
      backBtn.disabled = currentQuestionIndex === 0;
      backBtn.innerHTML = '<i class="fa-solid fa-arrow-left"></i> Kembali';
      if (currentQuestionIndex > 0) backBtn.onclick = prevQuestion;
      navDiv.appendChild(backBtn);

      var actionBtn = document.createElement('button');
      actionBtn.className = 'btn btn-primary';
      if (currentQuestionIndex < total - 1) {
        actionBtn.innerHTML = 'Lanjut <i class="fa-solid fa-arrow-right"></i>';
        actionBtn.onclick = nextQuestion;
      } else {
        actionBtn.innerHTML = '<i class="fa-solid fa-check"></i> Kirim';
        actionBtn.onclick = submitQuiz;
      }
      navDiv.appendChild(actionBtn);

      container.appendChild(navDiv);

      console.log('renderQuestion: DONE. quizContent.innerHTML AFTER:', container.innerHTML);
      console.log('quizContent childElementCount:', container.childElementCount);
    }

    function selectAnswer(qid, ans) {
      setAnswer(qid, ans);
      answeredQuestions[qid] = null;
      renderQuestion();
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

    function submitQuiz() {
      var result;
      try {
        result = window.submitQuizResult();
      } catch (e) {
        alert('Gagal submit quiz. Silakan coba lagi.');
        return;
      }

      var state = window._quizState;
      state.questions.forEach(function(q) {
        if (result.results) {
          var qResult = result.results.find(function(r) { return r.questionId === q.id; });
          if (qResult) {
            answeredQuestions[q.id] = qResult.isCorrect;
          }
        }
      });

      var container = document.getElementById('quizContent');

      var icon = result.passed ? 'fa-check-circle' : 'fa-times-circle';
      var iconClass = result.passed ? 'text-green-500' : 'text-red-500';
      var bgClass = result.passed ? 'from-green-50 to-emerald-50' : 'from-red-50 to-orange-50';
      var title = result.passed ? 'Alhamdulillah!' : 'Belum Lulus';
      var titleClass = result.passed ? 'text-green-600' : 'text-red-600';
      var msg = result.passed
        ? 'Semua jawabanmu benar!'
        : 'Skor: ' + result.score + '%. Syarat: 100%.';

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
        container.innerHTML += '<button onclick="retryQuiz()" class="btn btn-primary"><i class="fa-solid fa-redo"></i> Coba Lagi</button>';
        container.innerHTML += '<button onclick="closeQuiz()" class="btn btn-secondary"><i class="fa-solid fa-arrow-left"></i> Kembali</button>';
        container.innerHTML += '</div>';
      }
      container.innerHTML += '</div>';
    }

    async function handleQuizComplete(passed, score, correct, total) {
      var id = currentFasal ? currentFasal.id : currentBab.id;
      var attempts = 1;
      var existing = null;
      try { existing = await fetchFasalProgress(id); } catch (e) {}
      if (existing) attempts = (existing.quiz_attempts || 0) + 1;
      await saveProgress(id, score, attempts, passed ? 'completed' : 'unlocked');
      updateStatus({ status: passed ? 'completed' : 'unlocked', quiz_score: score });
    }

    function retryQuiz() {
      if (quizBankLoaded.length === 0) quizBankLoaded = quizBank;
      resetQuiz(quizBankLoaded);
      quizQuestions = window._quizState.questions;
      currentQuestionIndex = 0;
      selectedAnswers = {};
      answeredQuestions = {};
      renderQuestion();
    }

    function closeQuiz() {
      document.getElementById('quizModal').classList.add('hidden');
      document.body.style.overflow = '';
      window.location.href = 'student.html';
    }

    function handleLogout() {
      logout();
      window.location.href = 'auth.html';
    }

    // Audio Player for Student
    var studentAudio = null;
    var studentAudioUrl = null;
    var isStudentAudioPlaying = false;

    function initStudentAudioPlayer(audioUrl) {
      if (!audioUrl) {
        document.getElementById('audioPlayerSection').classList.add('hidden');
        return;
      }

      studentAudioUrl = audioUrl;
      document.getElementById('audioPlayerSection').classList.remove('hidden');

      studentAudio = new Audio(audioUrl);
      studentAudio.addEventListener('loadedmetadata', function() {
        var duration = studentAudio.duration;
        document.getElementById('studentAudioDuration').textContent = formatStudentTime(duration);
        drawStudentWaveform(audioUrl);
      });

      studentAudio.addEventListener('timeupdate', function() {
        var progress = (studentAudio.currentTime / studentAudio.duration) * 100;
        document.getElementById('studentAudioProgressFill').style.width = progress + '%';
        document.getElementById('studentAudioCurrentTime').textContent = formatStudentTime(studentAudio.currentTime);
      });

      studentAudio.addEventListener('ended', function() {
        isStudentAudioPlaying = false;
        document.getElementById('studentAudioPlayBtn').innerHTML = '<i class="fa-solid fa-play"></i>';
        document.getElementById('studentAudioPlayBtn').classList.remove('playing');
        document.getElementById('studentAudioProgressFill').style.width = '0%';
      });
    }

    function toggleStudentAudio() {
      if (!studentAudio) return;

      if (isStudentAudioPlaying) {
        studentAudio.pause();
        document.getElementById('studentAudioPlayBtn').innerHTML = '<i class="fa-solid fa-play"></i>';
        document.getElementById('studentAudioPlayBtn').classList.remove('playing');
      } else {
        studentAudio.play();
        document.getElementById('studentAudioPlayBtn').innerHTML = '<i class="fa-solid fa-pause"></i>';
        document.getElementById('studentAudioPlayBtn').classList.add('playing');
      }
      isStudentAudioPlaying = !isStudentAudioPlaying;
    }

    function seekStudentAudio(event) {
      if (!studentAudio) return;
      var progressBar = event.currentTarget;
      var rect = progressBar.getBoundingClientRect();
      var clickX = event.clientX - rect.left;
      var width = rect.width;
      var percentage = clickX / width;
      studentAudio.currentTime = studentAudio.duration * percentage;
    }

    function formatStudentTime(seconds) {
      if (isNaN(seconds)) return '00:00';
      var mins = Math.floor(seconds / 60);
      var secs = Math.floor(seconds % 60);
      return String(mins).padStart(2, '0') + ':' + String(secs).padStart(2, '0');
    }

    async function drawStudentWaveform(audioUrl) {
      var canvas = document.getElementById('studentWaveformCanvas');
      var ctx = canvas.getContext('2d');

      canvas.width = canvas.offsetWidth;
      canvas.height = 64;

      try {
        var audioContext = new (window.AudioContext || window.webkitAudioContext)();
        var response = await fetch(audioUrl);
        var arrayBuffer = await response.arrayBuffer();
        var audioBuffer = await audioContext.decodeAudioData(arrayBuffer);

        var data = audioBuffer.getChannelData(0);
        var step = Math.ceil(data.length / canvas.width);
        var amp = canvas.height / 2;

        ctx.fillStyle = 'var(--bg-base)';
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        ctx.strokeStyle = 'var(--purple)';
        ctx.lineWidth = 2;
        ctx.beginPath();

        for (var i = 0; i < canvas.width; i++) {
          var min = 1.0;
          var max = -1.0;
          for (var j = 0; j < step; j++) {
            var datum = data[(i * step) + j];
            if (datum < min) min = datum;
            if (datum > max) max = datum;
          }
          ctx.moveTo(i, (1 + min) * amp);
          ctx.lineTo(i, (1 + max) * amp);
        }

        ctx.stroke();
      } catch (err) {
        console.error('Waveform error:', err);
        ctx.fillStyle = 'var(--bg-base)';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        ctx.fillStyle = 'var(--purple)';
        for (var i = 0; i < 60; i++) {
          var height = Math.random() * 40 + 10;
          ctx.fillRect(i * (canvas.width / 60), (canvas.height - height) / 2, 3, height);
        }
      }
    }

    // Update loadBab and loadFasal to init audio
    var originalLoadBab = loadBab;
    loadBab = async function(babId) {
      await originalLoadBab(babId);
      if (currentBab && currentBab.audio_url) {
        initStudentAudioPlayer(currentBab.audio_url);
      }
    };

    var originalLoadFasal = loadFasal;
    loadFasal = async function(fasalId) {
      await originalLoadFasal(fasalId);
      if (currentFasal && currentFasal.audio_url) {
        initStudentAudioPlayer(currentFasal.audio_url);
      }
    };
  