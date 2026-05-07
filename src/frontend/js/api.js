/**
 * api.js — Supabase REST API Integration
 * Menghubungkan frontend ke Supabase backend
 *
 * Sebelum dipakai: salin .env.example → .env
 * lalu isi SUPABASE_URL dan SUPABASE_ANON_KEY
 */

const SUPABASE_URL = 'https://vbuailpfjyhianfhgpwc.supabase.co/';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZidWFpbHBmanloaWFuZmhncHdjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc5Nzk1NzgsImV4cCI6MjA5MzU1NTU3OH0.DFV5EqMzGsR7a1nSUdB7c_yW81lzgt1-KeVffcsPLGg';


// ================================================================
// AUTH
// ================================================================

/**
 * Login dengan email + password
 * @param {string} email
 * @param {string} password
 * @returns {Promise<{user, session}>}
 */
async function login(email, password) {
  const res = await fetch(`${SUPABASE_URL}auth/v1/token?grant_type=password`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'apikey': SUPABASE_ANON_KEY,
    },
    body: JSON.stringify({ email, password }),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.message || 'Login gagal');

  localStorage.setItem('SUPABASE_URL', SUPABASE_URL);
  localStorage.setItem('SUPABASE_ANON_KEY', SUPABASE_ANON_KEY);
  if (data.access_token) {
    localStorage.setItem('sb_access_token', data.access_token);
    localStorage.setItem('sb_refresh_token', data.refresh_token);
  }
  return data;
}

/**
 * Daftar akun baru
 * @param {string} email
 * @param {string} password
 * @param {string} fullName
 * @returns {Promise<{user}>}
 */
async function register(email, password, fullName) {
  const res = await fetch(`${SUPABASE_URL}auth/v1/signup`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'apikey': SUPABASE_ANON_KEY,
    },
    body: JSON.stringify({
      email,
      password,
      options: { data: { full_name: fullName, role: 'student' } }
    }),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.message || 'Registrasi gagal');
  return data;
}

/**
 * Logout — hapus semua token
 */
function logout() {
  localStorage.removeItem('sb_access_token');
  localStorage.removeItem('sb_refresh_token');
}

/**
 * Cek apakah user sudah login
 * @returns {Promise<object|null>}
 */
async function getCurrentUser() {
  const token = localStorage.getItem('sb_access_token');
  if (!token) return null;

  const res = await fetch(`${SUPABASE_URL}auth/v1/user`, {
    headers: { 'apikey': SUPABASE_ANON_KEY, 'Authorization': `Bearer ${token}` },
  });
  if (!res.ok) { logout(); return null; }
  return res.json();
}

/**
 * Ambil access token
 * @returns {string|null}
 */
function getToken() {
  return localStorage.getItem('sb_access_token');
}

/**
 * Ambil role user
 * @returns {string|null} 'admin', 'teacher', 'student', atau null
 */
function getUserRole() {
  return localStorage.getItem('sb_user_role');
}

/**
 * Cek apakah user adalah admin
 * @returns {boolean}
 */
function isAdmin() {
  return getUserRole() === 'admin';
}

/**
 * Simpan role user setelah login
 * @param {object} user
 */
function setUserRole(user) {
  // Ambil role dari metadata atau profiles
  const role = user.user_metadata?.role || user.role || 'student';
  localStorage.setItem('sb_user_role', role);
}

// ================================================================
// KURIKULUM
// ================================================================

/**
 * Ambil semua Bagian + Bab + Fasal (nested)
 * @returns {Promise<Array>}
 */
async function fetchKurikulum() {
  const token = getToken();
  const headers = {
    'apikey': SUPABASE_ANON_KEY,
    ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
  };

  const res = await fetch(
    `${SUPABASE_URL}rest/v1/bagian?select=*,bab(*,fasal(*,quiz(*)))&order=order_index`,
    { headers }
  );
  if (!res.ok) throw new Error('Gagal mengambil kurikulum');
  return res.json();
}

/**
 * Ambil detail satu Fasal
 * @param {string} fasalId
 * @returns {Promise<Object>}
 */
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
  if (!res.ok) throw new Error('Gagal mengambil fasal');
  const data = await res.json();
  return data[0] || null;
}

/**
 * Ambil semua quiz dari bank soal satu Fasal
 * @param {string} fasalId
 * @returns {Promise<Array>}
 */
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
    if (!res.ok) {
      console.error('fetchQuizBank error:', res.status, res.statusText);
      return [];
    }
    return res.json();
  } catch (err) {
    console.error('fetchQuizBank exception:', err);
    return [];
  }
}

/**
 * Ambil semua quiz dari bank soal satu Bab
 * @param {string} babId
 * @returns {Promise<Array>}
 */
async function fetchQuizBankBab(babId) {
  const token = getToken();
  const headers = {
    'apikey': SUPABASE_ANON_KEY,
    ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
  };

  try {
    console.log('fetchQuizBankBab: fetching for bab_id:', babId);
    const res = await fetch(
      `${SUPABASE_URL}rest/v1/quiz?bab_id=eq.${babId}&order=order_index`,
      { headers }
    );
    console.log('fetchQuizBankBab: response status:', res.status);
    if (!res.ok) {
      const text = await res.text();
      console.error('fetchQuizBankBab error:', res.status, text);
      return [];
    }
    const data = await res.json();
    console.log('fetchQuizBankBab: got', data.length, 'quizzes');
    return data;
  } catch (err) {
    console.error('fetchQuizBankBab exception:', err);
    return [];
  }
}

/**
 * Ambil progress untuk satu Bab
 * @param {string} babId
 * @returns {Promise<Object|null>}
 */
async function fetchBabProgress(babId) {
  const token = getToken();
  if (!token) return null;

  const user = await getCurrentUser();
  if (!user) return null;

  const encodedBabId = encodeURIComponent(babId);

  try {
    const res = await fetch(
      `${SUPABASE_URL}rest/v1/user_progress?user_id=eq.${user.id}&fasal_id=eq.${encodedBabId}&select=*`,
      {
        headers: {
          'apikey': SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${token}`,
        },
      }
    );
    if (!res.ok) {
      console.log('fetchBabProgress: skipping (user has no progress for bab yet)');
      return null; // No progress yet for new bab
    }
    const data = await res.json();
    return data[0] || null;
  } catch (err) {
    console.error('fetchBabProgress error:', err);
    return null; // Graceful fallback
  }
}

// ================================================================
// PROGRESS
// ================================================================

/**
 * Ambil semua progress user yang login
 * @returns {Promise<Array>}
 */
async function fetchUserProgress() {
  const token = getToken();
  if (!token) return [];

  const user = await getCurrentUser();
  if (!user) return [];

  const res = await fetch(
    `${SUPABASE_URL}rest/v1/user_progress?user_id=eq.${user.id}&select=*`,
    {
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${token}`,
      },
    }
  );
  if (!res.ok) return [];
  return res.json();
}

/**
 * Ambil progress untuk satu Fasal tertentu
 * @param {string} fasalId
 * @returns {Promise<Object|null>}
 */
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

/**
 * Simpan / update progress setelah kuis
 * @param {string} fasalId
 * @param {number} score
 * @param {number} attempts
 * @param {string} status 'in_progress' | 'completed'
 */
async function saveProgress(fasalId, score, attempts, status) {
  console.log('saveProgress called:', { fasalId, score, attempts, status });
  const token = getToken();
  console.log('token:', token ? 'exists' : 'null');
  if (!token) return;

  const user = await getCurrentUser();
  console.log('user:', user);
  if (!user) return;

  const body = {
    user_id: user.id,
    fasal_id: fasalId,
    quiz_score: score,
    quiz_attempts: attempts,
    status,
    completed_at: status === 'completed' ? new Date().toISOString() : null,
  };

  // Cek existing (skip check if fasalId contains bab_ prefix to avoid encoding issues)
  let existing = null;
  try {
    existing = await fetchFasalProgress(fasalId);
  } catch (e) {
    console.warn('Could not check existing progress:', e);
  }

  if (existing) {
    // Update
    const updateRes = await fetch(
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
    if (!updateRes.ok) {
      const err = await updateRes.text();
      console.error('Update progress failed:', err);
    }
  } else {
    // Insert baru
    const postBody = { ...body, started_at: new Date().toISOString() };
    console.log('Inserting new progress:', postBody);

    const insertRes = await fetch(`${SUPABASE_URL}rest/v1/user_progress`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${token}`,
        'Prefer': 'return=representation',
      },
      body: JSON.stringify(postBody),
    });

    if (!insertRes.ok) {
      const err = await insertRes.json();
      console.error('Insert progress failed:', err);
      // Try without optional fields
      const minimalBody = {
        user_id: user.id,
        fasal_id: fasalId,
        status,
        quiz_score: score,
        quiz_attempts: attempts
      };
      console.log('Retrying with minimal body:', minimalBody);

      const retryRes = await fetch(`${SUPABASE_URL}rest/v1/user_progress`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'apikey': SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${token}`,
          'Prefer': 'return=representation',
        },
        body: JSON.stringify(minimalBody),
      });

      if (!retryRes.ok) {
        const retryErr = await retryRes.json();
        console.error('Retry failed:', retryErr);
      } else {
        console.log('Retry successful!');
      }
    } else {
      const data = await insertRes.json();
      console.log('Progress inserted:', data);
    }
  }
}

/**
 * Unlock Fasal berikutnya (insert/update progress unlocked)
 * @param {string} fasalId
 */
async function unlockNextFasal(fasalId) {
  const token = getToken();
  if (!token) return;

  const user = await getCurrentUser();
  if (!user) return;

  const existing = await fetchFasalProgress(fasalId);
  if (!existing || existing.status === 'locked') {
    await fetch(`${SUPABASE_URL}rest/v1/user_progress`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${token}`,
        'Prefer': 'return=minimal',
      },
      body: JSON.stringify({
        user_id: user.id,
        fasal_id: fasalId,
        status: 'unlocked',
        started_at: new Date().toISOString(),
      }),
    });
  }
}

// ================================================================
// TEACHER / ADMIN — MANAGE MATERI
// ================================================================

/**
 * Buat Fasal baru (Teacher/Admin only)
 * @param {Object} fasalData
 */
async function createFasal(fasalData) {
  const token = getToken();
  if (!token) throw new Error('Harus login sebagai Teacher/Admin');

  const res = await fetch(`${SUPABASE_URL}rest/v1/fasal`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'apikey': SUPABASE_ANON_KEY,
      'Authorization': `Bearer ${token}`,
      'Prefer': 'return=representation',
    },
    body: JSON.stringify(fasalData),
  });
  if (!res.ok) {
    const err = await res.json();
    throw new Error(err.message || 'Gagal membuat fasal');
  }
  return res.json();
}

/**
 * Update Fasal
 * @param {string} fasalId
 * @param {Object} updates
 */
async function updateFasal(fasalId, updates) {
  const token = getToken();
  if (!token) throw new Error('Harus login');

  const res = await fetch(
    `${SUPABASE_URL}rest/v1/fasal?id=eq.${fasalId}`,
    {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${token}`,
        'Prefer': 'return=minimal',
      },
      body: JSON.stringify(updates),
    }
  );
  if (!res.ok) throw new Error('Gagal update fasal');
}

/**
 * Tambah soal ke bank (Teacher/Admin only)
 * @param {Object} quizData
 */
async function createQuiz(quizData) {
  const token = getToken();
  if (!token) throw new Error('Harus login sebagai Teacher/Admin');

  const res = await fetch(`${SUPABASE_URL}rest/v1/quiz`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'apikey': SUPABASE_ANON_KEY,
      'Authorization': `Bearer ${token}`,
      'Prefer': 'return=representation',
    },
    body: JSON.stringify(quizData),
  });
  if (!res.ok) {
    const err = await res.json();
    throw new Error(err.message || 'Gagal membuat soal');
  }
  return res.json();
}
