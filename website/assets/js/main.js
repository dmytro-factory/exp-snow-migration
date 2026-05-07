/* ==========================================
   AdventureWorks -> Snowflake Migration Showcase
   Interactions: nav, screenshots, gantt, scroll
   ========================================== */

(function() {
  'use strict';

  // Mobile nav toggle
  const navToggle = document.querySelector('.nav-toggle');
  const navLinks = document.querySelector('.nav-links');
  if (navToggle && navLinks) {
    navToggle.addEventListener('click', () => {
      const isHidden = navLinks.style.display === 'flex';
      navLinks.style.display = isHidden ? 'none' : 'flex';
      if (!isHidden) {
        navLinks.style.position = 'absolute';
        navLinks.style.top = '56px';
        navLinks.style.left = '0';
        navLinks.style.right = '0';
        navLinks.style.flexDirection = 'column';
        navLinks.style.background = 'rgba(10,10,10,0.95)';
        navLinks.style.padding = '16px 24px';
        navLinks.style.backdropFilter = 'blur(12px)';
        navLinks.style.borderBottom = '1px solid #2A2A2A';
      }
    });
  }

  // Screenshot carousel
  const screenshots = document.querySelectorAll('.screenshot');
  const dots = document.querySelectorAll('.dot');
  let currentShot = 0;
  let carouselInterval = null;

  function showShot(index) {
    screenshots.forEach((s, i) => s.classList.toggle('active', i === index));
    dots.forEach((d, i) => d.classList.toggle('active', i === index));
    currentShot = index;
  }

  function startCarousel() {
    if (carouselInterval) clearInterval(carouselInterval);
    carouselInterval = setInterval(() => {
      showShot((currentShot + 1) % screenshots.length);
    }, 5000);
  }

  dots.forEach((dot, i) => {
    dot.addEventListener('click', () => {
      showShot(i);
      startCarousel();
    });
  });

  if (screenshots.length > 0) {
    startCarousel();
  }

  // Smooth scroll for nav links
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
      const href = this.getAttribute('href');
      if (!href || href === '#') return;
      const target = document.querySelector(href);
      if (target) {
        e.preventDefault();
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
        if (navLinks) navLinks.style.display = 'none';
      }
    });
  });

  // Gantt chart rendering — with Worker + Validator sub-bars
  function renderGantt() {
    const container = document.getElementById('gantt-chart');
    if (!container) return;

    // Each milestone: total span, worker sub-segments, validator sub-segments, pushback events
    const milestones = [
      {
        name: 'M1 Discovery', start: 0, end: 8, color: '#C586C0', icon: '&#128270;',
        workers: [{ start: 0, end: 5 }],
        validators: [
          { start: 4, end: 5.5, type: 'scrutiny', status: 'reject' },
          { start: 5.5, end: 6.5, type: 'scrutiny', status: 'pass' },
          { start: 6, end: 7, type: 'user', status: 'reject' },
          { start: 7, end: 8, type: 'user', status: 'pass' }
        ]
      },
      {
        name: 'M2 Architecture', start: 8, end: 16, color: '#4EC9B0', icon: '&#128736;',
        workers: [{ start: 8, end: 12.5 }],
        validators: [
          { start: 11, end: 12.5, type: 'scrutiny', status: 'pass' },
          { start: 13, end: 14, type: 'user', status: 'reject' },
          { start: 14, end: 15, type: 'user', status: 'pass' },
          { start: 14.5, end: 15.5, type: 'scrutiny', status: 'pass' }
        ]
      },
      {
        name: 'M3 DDL', start: 16, end: 28, color: '#569CD6', icon: '&#128196;',
        workers: [{ start: 16, end: 22 }],
        validators: [
          { start: 20, end: 22, type: 'scrutiny', status: 'reject' },
          { start: 22, end: 24, type: 'scrutiny', status: 'pass' },
          { start: 24, end: 25.5, type: 'user', status: 'pass' }
        ]
      },
      {
        name: 'M4 Notebooks', start: 28, end: 48, color: '#569CD6', icon: '&#128218;',
        workers: [{ start: 28, end: 38 }],
        validators: [
          { start: 35, end: 37, type: 'scrutiny', status: 'reject' },
          { start: 37, end: 40, type: 'scrutiny', status: 'pass' },
          { start: 40, end: 42, type: 'user', status: 'reject' },
          { start: 42, end: 45, type: 'user', status: 'pass' },
          { start: 45, end: 47, type: 'scrutiny', status: 'pass' }
        ]
      },
      {
        name: 'M5 Data Migration', start: 48, end: 78, color: '#CE9178', icon: '&#128230;',
        workers: [{ start: 48, end: 62 }, { start: 66, end: 72 }], // two worker rounds
        validators: [
          { start: 58, end: 60, type: 'scrutiny', status: 'reject' },
          { start: 60, end: 64, type: 'scrutiny', status: 'pass' },
          { start: 64, end: 66, type: 'user', status: 'reject' },
          { start: 70, end: 73, type: 'user', status: 'pass' },
          { start: 73, end: 76, type: 'scrutiny', status: 'pass' }
        ]
      },
      {
        name: 'M6 Dashboard', start: 78, end: 102, color: '#DCDCAA', icon: '&#128200;', textDark: true,
        workers: [{ start: 78, end: 88 }],
        validators: [
          { start: 85, end: 87, type: 'scrutiny', status: 'reject' },
          { start: 87, end: 90, type: 'scrutiny', status: 'pass' },
          { start: 90, end: 92, type: 'user', status: 'reject' },
          { start: 92, end: 96, type: 'user', status: 'pass' },
          { start: 96, end: 99, type: 'scrutiny', status: 'pass' }
        ]
      },
      {
        name: 'M7 Validation', start: 102, end: 126, color: '#B5CEA8', icon: '&#9989;', textDark: true,
        workers: [{ start: 102, end: 112 }],
        validators: [
          { start: 108, end: 110, type: 'scrutiny', status: 'reject' },
          { start: 110, end: 114, type: 'scrutiny', status: 'pass' },
          { start: 114, end: 116, type: 'user', status: 'reject' },
          { start: 116, end: 120, type: 'user', status: 'pass' },
          { start: 120, end: 124, type: 'scrutiny', status: 'pass' }
        ]
      }
    ];

    const totalMinutes = 126;
    const rowHeight = 56;
    const rowGap = 20;
    const labelWidth = 160;
    const chartPad = 20;
    const subBarHeight = 14;
    const subBarGap = 4;
    const svgWidth = container.clientWidth || 800;
    const chartWidth = svgWidth - labelWidth - chartPad * 2;
    const svgHeight = milestones.length * (rowHeight + rowGap) + chartPad * 2 + 50; // extra for legend

    let svg = `<svg width="${svgWidth}" height="${svgHeight}" xmlns="http://www.w3.org/2000/svg" style="font-family: 'Geist Mono', monospace;">`;

    // defs for patterns
    svg += `<defs>`;
    svg += `<pattern id="stripe-reject" patternUnits="userSpaceOnUse" width="6" height="6" patternTransform="rotate(45)">`;
    svg += `<line x1="0" y1="0" x2="0" y2="6" stroke="rgba(255,255,255,0.3)" stroke-width="2"/>`;
    svg += `</pattern>`;
    svg += `<filter id="glow-pass" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="2" result="blur"/><feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge></filter>`;
    svg += `</defs>`;

    // Background grid
    const gridSteps = 7;
    for (let i = 0; i <= gridSteps; i++) {
      const x = labelWidth + chartPad + (chartWidth / gridSteps) * i;
      const minutes = Math.round((totalMinutes / gridSteps) * i);
      const hours = Math.floor(minutes / 60);
      const mins = minutes % 60;
      const timeLabel = hours > 0 ? `${hours}h${mins > 0 ? mins + 'm' : ''}` : `${mins}m`;
      svg += `<line x1="${x}" y1="${chartPad}" x2="${x}" y2="${svgHeight - chartPad - 50}" stroke="#2A2A2A" stroke-width="1" stroke-dasharray="3 3"/>`;
      svg += `<text x="${x}" y="${chartPad - 6}" fill="#6B6B6B" font-size="10" text-anchor="middle">${timeLabel}</text>`;
    }

    milestones.forEach((m, i) => {
      const yBase = chartPad + i * (rowHeight + rowGap);
      const textColor = m.textDark ? '#1A1A1A' : '#F5F5F5';

      // Label
      svg += `<text x="${labelWidth - 10}" y="${yBase + rowHeight/2 + 4}" fill="#A0A0A0" font-size="12" text-anchor="end" font-weight="500">${m.icon} ${m.name}</text>`;

      // Background track bar (subtle)
      const trackX = labelWidth + chartPad + (m.start / totalMinutes) * chartWidth;
      const trackW = ((m.end - m.start) / totalMinutes) * chartWidth;
      svg += `<rect x="${trackX}" y="${yBase}" width="${trackW}" height="${rowHeight}" rx="8" fill="${m.color}" opacity="0.08"/>`;

      // Worker bars (bottom sub-bar) — keep text
      m.workers.forEach(w => {
        const wx = labelWidth + chartPad + (w.start / totalMinutes) * chartWidth;
        const ww = ((w.end - w.start) / totalMinutes) * chartWidth;
        const wy = yBase + rowHeight - subBarHeight;
        svg += `<rect x="${wx}" y="${wy}" width="${ww}" height="${subBarHeight}" rx="3" fill="#22C55E" opacity="0.7"/>`;
        svg += `<text x="${wx + ww/2}" y="${wy + subBarHeight/2 + 3}" fill="#0A0A0A" font-size="8" text-anchor="middle" font-weight="600">WORKER</text>`;
      });

      // Validator bars (top sub-bar) — colors only, no text labels
      m.validators.forEach(v => {
        const vx = labelWidth + chartPad + (v.start / totalMinutes) * chartWidth;
        const vw = ((v.end - v.start) / totalMinutes) * chartWidth;
        const vy = yBase;
        const isReject = v.status === 'reject';
        const isScrutiny = v.type === 'scrutiny';
        const baseColor = isScrutiny ? '#FF6B35' : '#569CD6';
        const strokeColor = isReject ? '#EF4444' : 'none';
        const fillOpacity = isReject ? '0.5' : '0.7';
        const pattern = isReject ? 'url(#stripe-reject)' : 'none';
        const filter = !isReject ? 'url(#glow-pass)' : 'none';
        const sw = isReject ? 2 : 0;

        svg += `<rect x="${vx}" y="${vy}" width="${vw}" height="${subBarHeight}" rx="3" fill="${baseColor}" fill-opacity="${fillOpacity}" stroke="${strokeColor}" stroke-width="${sw}" filter="${filter}"/>`;
        if (isReject) {
          svg += `<rect x="${vx}" y="${vy}" width="${vw}" height="${subBarHeight}" rx="3" fill="${pattern}" opacity="0.4" pointer-events="none"/>`;
        }
      });

      // Duration label on the track
      const dur = m.end - m.start;
      const durText = dur >= 60 ? `${Math.floor(dur/60)}h${dur%60 > 0 ? (dur%60)+'m' : ''}` : `${dur}m`;
      svg += `<text x="${trackX + trackW + 8}" y="${yBase + rowHeight/2 + 4}" fill="${m.color}" font-size="11" font-weight="600" opacity="0.8">${durText}</text>`;
    });

    // Legend — 3 clean items, no overlap
    const legendY = svgHeight - 36;
    const legStart = labelWidth + chartPad;
    const legSpacing = 160;

    // Worker
    svg += `<rect x="${legStart}" y="${legendY}" width="12" height="8" rx="2" fill="#22C55E" opacity="0.7"/>`;
    svg += `<text x="${legStart + 18}" y="${legendY + 7}" fill="#A0A0A0" font-size="10">Worker</text>`;

    // Scrutiny Validator
    svg += `<rect x="${legStart + legSpacing}" y="${legendY}" width="12" height="8" rx="2" fill="#FF6B35" opacity="0.7"/>`;
    svg += `<text x="${legStart + legSpacing + 18}" y="${legendY + 7}" fill="#A0A0A0" font-size="10">Scrutiny Validator</text>`;

    // User-Testing Validator
    svg += `<rect x="${legStart + legSpacing * 2}" y="${legendY}" width="12" height="8" rx="2" fill="#569CD6" opacity="0.7"/>`;
    svg += `<text x="${legStart + legSpacing * 2 + 18}" y="${legendY + 7}" fill="#A0A0A0" font-size="10">User-Testing Validator</text>`;

    svg += `</svg>`;
    container.innerHTML = svg;
  }

  renderGantt();
  window.addEventListener('resize', renderGantt);

  // Lightbox for dashboard thumbnails
  (function initLightbox() {
    const thumbs = document.querySelectorAll('.lightbox-thumb');
    if (!thumbs.length) return;

    let overlay = null, overlayImg = null, overlayCaption = null;

    function openLightbox(src, caption) {
      if (!overlay) {
        overlay = document.createElement('div');
        overlay.className = 'lightbox-overlay';
        overlay.innerHTML = `
          <button class="lightbox-close">&times;</button>
          <img src="" alt="">
          <div class="lightbox-caption"></div>
        `;
        document.body.appendChild(overlay);
        overlay.querySelector('.lightbox-close').addEventListener('click', closeLightbox);
        overlay.addEventListener('click', (e) => { if (e.target === overlay) closeLightbox(); });
        overlayImg = overlay.querySelector('img');
        overlayCaption = overlay.querySelector('.lightbox-caption');
      }
      overlayImg.src = src;
      overlayCaption.textContent = caption || '';
      requestAnimationFrame(() => overlay.classList.add('active'));
      document.addEventListener('keydown', onKey);
    }

    function closeLightbox() {
      if (overlay) overlay.classList.remove('active');
      document.removeEventListener('keydown', onKey);
    }

    function onKey(e) {
      if (e.key === 'Escape') closeLightbox();
    }

    thumbs.forEach(t => {
      t.addEventListener('click', (e) => {
        e.preventDefault();
        openLightbox(t.getAttribute('href'), t.getAttribute('data-caption'));
      });
    });
  })();

  // Intersection Observer for fade-in animations
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
      }
    });
  }, { threshold: 0.1 });

  document.querySelectorAll('.overview-card, .milestone, .val-card, .gallery-card, .exec-card').forEach(el => {
    el.classList.add('reveal');
    observer.observe(el);
  });
})();
