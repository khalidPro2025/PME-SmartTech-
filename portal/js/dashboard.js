async function loadStatus() {
  try {
    const r = await apiFetch('/services');
    if (!r.ok) { document.getElementById('statusList').innerText = 'API inaccessible'; return; }
    const services = await r.json();
    const el = document.getElementById('statusList');
    el.innerHTML = '';
    for (const [name, host] of Object.entries(services)) {
      const s = document.createElement('div');
      s.className = 'flex justify-between items-center';
      s.innerHTML = `<div class="font-medium">${name}</div><div id="st-${name}" class="text-sm text-gray-600">?</div>`;
      el.appendChild(s);
      checkStatus(name);
    }
  } catch (e) {
    document.getElementById('statusList').innerText = 'Erreur: ' + e;
  }
}

async function checkStatus(name) {
  try {
    const r = await apiFetch('/services/status/' + name);
    const j = await r.json();
    const el = document.getElementById('st-' + name);
    el.innerText = j.status || (j.error ? 'DOWN' : 'UNKNOWN');
    if (j.status === 'UP') el.className = 'text-green-600';
    else el.className = 'text-red-600';
    // append logs if available
    const logsBox = document.getElementById('logs');
    logsBox.innerText = JSON.stringify(j, null, 2);
  } catch (e) {
    document.getElementById('st-' + name).innerText = 'ERR';
  }
}

// simple simulated CPU chart with random values (replace with real metrics later)
const ctx = document.getElementById('cpuChart')?.getContext('2d');
let cpuChart;
if (ctx) {
  cpuChart = new Chart(ctx, {
    type: 'line',
    data: {
      labels: Array.from({length:10}, (_,i) => i),
      datasets: [{label:'CPU %', data: Array.from({length:10}, ()=>Math.random()*30+10), fill:false, tension:0.3}]
    },
    options: {responsive:true, plugins:{legend:{display:false}}}
  });
  setInterval(()=> {
    cpuChart.data.datasets[0].data.shift();
    cpuChart.data.datasets[0].data.push(Math.round(Math.random()*50+10));
    cpuChart.update();
  },3000);
}

document.getElementById('btnLogout')?.addEventListener('click', () => {
  localStorage.removeItem('st_token');
  location.href = '/login.html';
});

loadStatus();
