/*
 * Nhúng viewer 3D bằng 1 dòng duy nhất — không cần biết code.
 * Khách hàng chỉ dán dòng sau vào trang web của họ:
 *
 *   <script src="https://TEN-MIEN-CUA-BAN/choisy/embed.js" data-height="600px" data-autorotate="1"></script>
 *
 * Mọi tuỳ chọn của viewer truyền qua thuộc tính data-*:
 *   data-height     chiều cao khung (mặc định 600px)
 *   data-radius     bán kính giới hạn di chuyển, mét (mặc định 150)
 *   data-mpu        số mét / 1 đơn vị scene (mặc định 10)
 *   data-center     tâm giới hạn "x,y,z"
 *   data-pos        vị trí camera ban đầu "x,y,z"
 *   data-fov        góc nhìn (độ)
 *   data-bg         màu nền hex, vd "1a1d24"
 *   data-autorotate "1" = tự xoay đến khi khách chạm vào
 *   data-elev       giới hạn góc cao "min,max" độ
 *   data-ui         "0" = ẩn nút và gợi ý điều khiển
 *   data-rounded    bo góc khung, vd "12px"
 */
(function () {
    var s = document.currentScript;
    if (!s) return;

    var base = s.src.replace(/embed\.js.*$/, 'index.html');
    var keys = ['radius', 'mpu', 'center', 'pos', 'fov', 'bg', 'autorotate', 'elev', 'ui', 'src'];
    var params = [];
    for (var i = 0; i < keys.length; i++) {
        var v = s.getAttribute('data-' + keys[i]);
        if (v !== null && v !== '') params.push(keys[i] + '=' + encodeURIComponent(v));
    }

    var iframe = document.createElement('iframe');
    iframe.src = base + (params.length ? '?' + params.join('&') : '');
    iframe.style.cssText =
        'width:100%;height:' + (s.getAttribute('data-height') || '600px') +
        ';border:0;display:block;background:#000;border-radius:' +
        (s.getAttribute('data-rounded') || '0');
    iframe.allowFullscreen = true;
    iframe.setAttribute('allow', 'fullscreen');
    iframe.setAttribute('loading', 'lazy');
    iframe.title = '3D Viewer';

    s.parentNode.insertBefore(iframe, s);
})();
