(function(){
  var KEY='trendflow-theme';
  var root=document.documentElement;
  function preferred(){
    try{
      var saved=localStorage.getItem(KEY);
      if(saved==='light'||saved==='dark') return saved;
    }catch(e){}
    return window.matchMedia&&window.matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light';
  }
  function apply(theme){
    root.setAttribute('data-theme',theme);
    try{localStorage.setItem(KEY,theme);}catch(e){}
    var isDark=theme==='dark';
    document.querySelectorAll('[data-theme-toggle]').forEach(function(btn){
      btn.setAttribute('aria-label',isDark?'라이트 모드로 전환':'다크 모드로 전환');
      btn.setAttribute('title',isDark?'라이트 모드로 전환':'다크 모드로 전환');
      var icon=btn.querySelector('[data-theme-icon]');
      var label=btn.querySelector('[data-theme-label]');
      if(icon) icon.textContent=isDark?'☀️':'🌙';
      if(label) label.textContent=isDark?'라이트':'다크';
    });
  }
  function init(){
    apply(root.getAttribute('data-theme')||preferred());
    document.querySelectorAll('[data-theme-toggle]').forEach(function(btn){
      btn.addEventListener('click',function(){
        apply((root.getAttribute('data-theme')||preferred())==='dark'?'light':'dark');
      });
    });
  }
  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded',init); else init();
})();
