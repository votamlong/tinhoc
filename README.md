# Quản lý trường học

Website quản lý trường học (HTML + JavaScript thuần), dữ liệu lưu trên **Supabase**, có đăng nhập và phân quyền.

## Phân quyền

| Vai trò | Quyền |
|---|---|
| Quản trị (admin) | Xem và sửa tất cả: học sinh, giáo viên, lớp, điểm, điểm danh |
| Giáo viên | Xem tất cả; chỉ nhập được điểm số và điểm danh |

Phân quyền được kiểm tra ở phía máy chủ (Row Level Security), không thể vượt qua bằng cách sửa code trên trình duyệt.

## Cài đặt Supabase (một lần)

1. Tạo tài khoản miễn phí tại https://supabase.com, bấm **New project**.
2. Vào **SQL Editor**, dán toàn bộ nội dung `supabase-setup.sql`, bấm **Run**.
3. Vào **Authentication → Providers → Email**: tắt **Allow new users to sign up** (để người ngoài không tự đăng ký).
4. Vào **Authentication → Users → Add user**: tạo tài khoản admin (email + mật khẩu, tick Auto Confirm User).
5. Quay lại SQL Editor, chạy dòng `update profiles set role = 'admin' ...` ở cuối file SQL (đổi đúng email admin).
6. Vào **Project Settings → API**, copy **Project URL** và **anon public key**, dán vào đầu phần `<script>` trong `index.html`:
   ```js
   const SUPABASE_URL = 'https://xxxx.supabase.co';
   const SUPABASE_ANON_KEY = 'eyJ...';
   ```
   Khóa `anon` được phép công khai. Tuyệt đối **không** dùng khóa `service_role` trong code.

## Thêm giáo viên

Authentication → Users → Add user. Tài khoản mới tự động là giáo viên. Muốn đổi thành admin, chạy lệnh `update profiles set role = 'admin' ...`.

## Đưa lên GitHub Pages

Upload `index.html`, `README.md`, `supabase-setup.sql` lên repo, rồi Settings → Pages → Deploy from a branch → `main` / `(root)`.
Sau đó vào Supabase → Authentication → URL Configuration, thêm link GitHub Pages vào **Site URL**.

## Lưu ý

- Dữ liệu mỗi loại (học sinh, điểm, điểm danh...) lưu thành một bản ghi JSON. Nếu hai người sửa **cùng lúc**, người lưu sau sẽ ghi đè người trước. Phù hợp trường nhỏ; trường lớn nên tách thành các bảng SQL riêng.
- Hãy sao lưu định kỳ (Supabase → Database → Backups, hoặc nút Xuất CSV).
