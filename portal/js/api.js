// helpers to call API with JWT stored in localStorage
const API_BASE = 'https://api.smarttech.local';

async function apiFetch(path, opts = {}) {
  const token = localStorage.getItem('st_token');
  opts.headers = opts.headers || {};
  opts.headers['Content-Type'] = opts.headers['Content-Type'] || 'application/json';
  if (token) opts.headers['Authorization'] = 'Bearer ' + token;
  const r = await fetch(API_BASE + path, opts);
  return r;
}
