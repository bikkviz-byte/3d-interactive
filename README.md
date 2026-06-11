# Choisy 3DGS Viewer — giới hạn phạm vi di chuyển

Bộ công cụ xem 3D Gaussian Splatting cho dự án Choisy (2.092.829 splats, định dạng SOG).

**Nguyên tắc:** chỉ giới hạn **phạm vi di chuyển** của camera (mặt cầu bán kính ~150 m
quanh công trình). Góc nhìn hoàn toàn tự do, **không cắt/ẩn splat nào**, dữ liệu splat
**giữ nguyên không chỉnh sửa**.

## Quy trình làm việc chính

1. **Mở studio** (`studio.html`) → kéo-thả file `.ply` / `.sog` / `.html` (export SuperSplat)
2. **Review**: xem số splat, xoay thử, chỉnh bán kính giới hạn (nhìn thấy mặt cầu trực quan)
3. **Xuất file khoá**: bấm "⬇️ Xuất file HTML khoá (gửi khách)" → tải về 1 file
   `*-locked.html` tự chứa (dữ liệu splat nhúng nguyên vẹn bên trong)
4. **Gửi khách** file đó + mã nhúng (nút "📋 Sao chép mã nhúng"). Khách upload file
   lên hosting của họ và dán mã nhúng vào trang web:

```html
<iframe src="https://ten-mien-khach/index-locked.html"
        style="width:100%;height:600px;border:0" allowfullscreen></iframe>
```

**Khách không thể tự thay đổi giới hạn di chuyển**: file xuất ghi cứng cấu hình thành
hằng số bên trong, hoàn toàn không đọc tham số URL — không có "núm" nào để vặn.
Góc nhìn lúc bạn bấm xuất chính là góc mở đầu khách nhìn thấy.

## Cấu trúc thư mục

| File | Vai trò |
|---|---|
| `studio.html` | **Công cụ nội bộ**: xem trước, đọc số splat, chỉnh giới hạn di chuyển, xuất file khoá |
| `locked-template.html` | Khuôn để studio sinh file khoá (đừng xoá — studio cần nó) |
| `index.html` | Viewer linh hoạt cấu hình qua URL param — dùng khi BẠN tự host |
| `index.sog` | Dữ liệu splat Choisy (32 MB) |
| `embed.js` + `embed-example.html` | Nhúng 1 dòng + trang demo (cho phương án tự host) |
| `serve.ps1` | Server tĩnh thuần PowerShell để chạy thử trên máy |

## Chạy thử trên máy

File splat phải được tải qua HTTP (mở trực tiếp bằng `file://` sẽ không chạy):

```powershell
cd choisy-splat-viewer
powershell -ExecutionPolicy Bypass -File serve.ps1
# rồi mở http://localhost:8173/studio.html
```

(Nếu máy có Node.js thì `npx -y http-server -p 8080` cũng được.
Riêng file `*-locked.html` đã xuất thì tự chứa, mở thử qua server nào cũng được.)

## Studio — chi tiết

Kéo-thả một trong các loại file:

- **`.ply`** — Gaussian splat PLY tiêu chuẩn
- **`.sog`** — định dạng nén SOG
- **`.html`** — file export "HTML viewer" của SuperSplat: studio tự **trích xuất dữ liệu
  splat nhúng base64** bên trong và lấy đúng camera + tâm công trình từ settings nhúng

Panel chỉ có đúng những thứ cần: **số splat** (+ dung lượng, kích thước scene),
**bán kính giới hạn (m)**, **tỉ lệ mét/đơn vị**, bật/tắt mặt cầu minh hoạ, tự xoay,
và 2 nút đặt tâm giới hạn (theo tâm scene / theo tâm nhìn hiện tại).

Với file `.ply`/`.sog` không kèm settings, studio tự tính tâm theo **median vị trí
splat** nên không bị lệch bởi splat nền ở xa (scene Choisy có lớp nền cách tâm ~700 đơn vị).

## ⚠️ Hiệu chỉnh tỉ lệ (`mpu`) — nên làm 1 lần cho mỗi scene

Scene 3DGS không có đơn vị mét chuẩn. Với scene Choisy: vùng công trình gói trong
~10–20 **đơn vị scene**, lớp nền (trời, thành phố xa) trải tới ~700 đơn vị.
Mặc định giả định **1 đơn vị ≈ 10 m** (`mpu=10`), tức bán kính 150 m = 15 đơn vị.

Hiệu chỉnh chính xác: đo một kích thước đã biết của công trình trong SuperSplat
(ví dụ mặt đứng 40 m đo được 4,2 đơn vị → `mpu = 40 / 4,2 ≈ 9,5`), nhập vào ô
"Mét / đơn vị scene" trong studio trước khi xuất.

## Phương án phụ: tự host viewer cấu hình bằng URL

Nếu bạn tự host thư mục này, `index.html` nhận URL param (`radius`, `mpu`, `center`,
`pos`, `fov`, `bg`, `autorotate`, `ui`, `src`; góc nhìn mặc định tự do `-89,89`),
và `embed.js` cho khách nhúng 1 dòng. **Lưu ý:** phương án này ai sửa được link nhúng
thì đổi được tham số — muốn khoá tuyệt đối với khách, dùng file xuất từ studio.

## Điều khiển

- **Chuột:** kéo trái = xoay · lăn = thu phóng · kéo phải (hoặc Shift+kéo) = di chuyển tâm nhìn
- **Cảm ứng:** 1 ngón = xoay · 2 ngón = thu phóng + di chuyển
- Giới hạn duy nhất: camera bị chặn tại mặt cầu bán kính đã đặt; tâm nhìn (pan)
  giữ trong nửa bán kính quanh công trình. Góc nhìn tự do (chỉ chặn ±89° chống lật trục).

## Lưu ý kỹ thuật

- Engine PlayCanvas tải từ CDN jsDelivr (`playcanvas@2`) — trang hiển thị cần internet.
- File `*-locked.html` nặng ≈ dung lượng splat × 1,33 (base64) — scene Choisy ra ~41 MB.
  Khuyên khách dùng hosting có CDN/nén để tải nhanh.
- "Khoá" ở đây = không có tham số/UI nào để đổi giới hạn. Về lý thuyết mọi file chạy
  phía trình duyệt đều có thể bị người biết code mổ ra sửa — không có cách nào chặn
  tuyệt đối 100% với nội dung web; mức khoá này đủ cho mục đích thương mại thông thường.
- Viewer xoay splat `(0,0,180°)` giống viewer SuperSplat gốc nên giữ nguyên góc camera
  của file export.
