(function(){
  var THEME_KEY='trendflow-theme';
  var root=document.documentElement;

  function preferredTheme(){
    try{
      var saved=localStorage.getItem(THEME_KEY);
      if(saved==='light'||saved==='dark') return saved;
    }catch(e){}
    return window.matchMedia&&window.matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light';
  }

  function applyTheme(theme){
    root.setAttribute('data-theme',theme);
    try{localStorage.setItem(THEME_KEY,theme);}catch(e){}

    var isDark=theme==='dark';
    document.querySelectorAll('[data-theme-toggle]').forEach(function(btn){
      var nextLabel=isDark?'라이트 모드로 전환':'다크 모드로 전환';
      btn.setAttribute('aria-label',nextLabel);
      btn.setAttribute('title',nextLabel);

      var icon=btn.querySelector('[data-theme-icon]');
      var label=btn.querySelector('[data-theme-label]');
      if(icon) icon.textContent=isDark?'☀':'☾';
      if(label) label.textContent=isDark?'라이트':'다크';
    });
  }

  function initThemeToggle(){
    applyTheme(root.getAttribute('data-theme')||preferredTheme());
    document.querySelectorAll('[data-theme-toggle]').forEach(function(btn){
      btn.addEventListener('click',function(){
        var current=root.getAttribute('data-theme')||preferredTheme();
        applyTheme(current==='dark'?'light':'dark');
      });
    });
  }

  function initHomeHeroSlider(){
    document.querySelectorAll('[data-home-hero-slider]').forEach(function(slider){
      var slides=Array.prototype.slice.call(slider.querySelectorAll('[data-home-hero-slide]'));
      var dots=Array.prototype.slice.call(slider.querySelectorAll('[data-home-hero-dot]'));
      var prev=slider.querySelector('[data-home-hero-prev]');
      var next=slider.querySelector('[data-home-hero-next]');
      if(slides.length<2) return;

      var index=0;
      var timer=null;
      var prefersReducedMotion=window.matchMedia&&window.matchMedia('(prefers-reduced-motion: reduce)').matches;

      function show(nextIndex){
        index=(nextIndex+slides.length)%slides.length;
        slides.forEach(function(slide,i){
          var active=i===index;
          slide.classList.toggle('is-active',active);
          slide.setAttribute('aria-hidden',active?'false':'true');
        });
        dots.forEach(function(dot,i){
          dot.setAttribute('aria-current',i===index?'true':'false');
        });
      }

      function stop(){
        if(timer){
          window.clearInterval(timer);
          timer=null;
        }
      }

      function start(){
        if(prefersReducedMotion||timer) return;
        timer=window.setInterval(function(){show(index+1);},5000);
      }

      dots.forEach(function(dot,i){
        dot.addEventListener('click',function(){
          stop();
          show(i);
          start();
        });
      });
      if(prev){
        prev.addEventListener('click',function(){
          stop();
          show(index-1);
          start();
        });
      }
      if(next){
        next.addEventListener('click',function(){
          stop();
          show(index+1);
          start();
        });
      }

      slider.addEventListener('mouseenter',stop);
      slider.addEventListener('mouseleave',start);
      slider.addEventListener('focusin',stop);
      slider.addEventListener('focusout',start);
      document.addEventListener('visibilitychange',function(){
        if(document.hidden) stop();
        else start();
      });

      show(0);
      start();
    });
  }

  function init(){
    initThemeToggle();
    initHomeHeroSlider();
  }

  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded',init);
  else init();
})();
