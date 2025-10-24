// モバイルメニューの制御（Vanilla JavaScript）
console.log('Mobile menu script loaded');

document.addEventListener('DOMContentLoaded', function () {
  console.log('DOM loaded, initializing mobile menu');
  initializeMobileMenu();
});

document.addEventListener('turbo:load', function () {
  console.log('Turbo load, initializing mobile menu');
  initializeMobileMenu();
});

function initializeMobileMenu() {
  console.log('Initializing mobile menu...');

  const mobileMenuButton = document.querySelector('[data-mobile-menu-target="menuButton"]');
  const mobileMenuClose = document.querySelector('[data-mobile-menu-target="closeButton"]');
  const sidebar = document.querySelector('[data-mobile-menu-target="sidebar"]');
  const overlay = document.querySelector('[data-mobile-menu-target="overlay"]');

  console.log('Elements found:', {
    mobileMenuButton: !!mobileMenuButton,
    mobileMenuClose: !!mobileMenuClose,
    sidebar: !!sidebar,
    overlay: !!overlay
  });

  if (!sidebar) {
    console.log('Sidebar not found, skipping initialization');
    return;
  }

  // サイドバーを開く
  function openSidebar() {
    console.log('Opening sidebar');
    sidebar.classList.remove('-translate-x-full');
    sidebar.classList.add('translate-x-0');
    if (overlay) {
      overlay.classList.remove('hidden');
    }
    document.body.classList.add('overflow-hidden');
  }

  // サイドバーを閉じる
  function closeSidebar() {
    console.log('Closing sidebar');
    sidebar.classList.add('-translate-x-full');
    sidebar.classList.remove('translate-x-0');
    if (overlay) {
      overlay.classList.add('hidden');
    }
    document.body.classList.remove('overflow-hidden');
  }

  // ハンバーガーメニューボタン
  if (mobileMenuButton) {
    console.log('Adding click listener to mobile menu button');
    mobileMenuButton.addEventListener('click', function (e) {
      console.log('Mobile menu button clicked');
      e.preventDefault();
      openSidebar();
    });
  } else {
    console.log('Mobile menu button not found');
  }

  // 閉じるボタン
  if (mobileMenuClose) {
    console.log('Adding click listener to close button');
    mobileMenuClose.addEventListener('click', function (e) {
      console.log('Close button clicked');
      e.preventDefault();
      closeSidebar();
    });
  }

  // オーバーレイクリック
  if (overlay) {
    console.log('Adding click listener to overlay');
    overlay.addEventListener('click', function (e) {
      console.log('Overlay clicked');
      e.preventDefault();
      closeSidebar();
    });
  }

  // ESCキーで閉じる
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
      console.log('ESC key pressed');
      closeSidebar();
    }
  });

  // ウィンドウリサイズ時の処理
  window.addEventListener('resize', function () {
    if (window.innerWidth >= 1024) { // lg breakpoint
      console.log('Window resized to desktop size, closing sidebar');
      closeSidebar();
    }
  });
}
