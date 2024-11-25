// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "./photo_upload"

//ハンバーガーメニュー
document.getElementById('menu-toggle').addEventListener('click', function() {
  var navbarCollapse = document.getElementById('navbarNav');
  navbarCollapse.classList.toggle('active');
});