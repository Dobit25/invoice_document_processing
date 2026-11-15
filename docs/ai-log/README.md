# AI Assistance Log

Thư mục này ghi lại việc sử dụng AI trong quá trình xây dựng StatementReader để nhóm có thể giải thích nguồn gốc artifact, quyết định của con người và cách kiểm chứng.

## Khi nào cần tạo log?

Tạo hoặc cập nhật một entry khi AI được dùng để nghiên cứu, thiết kế, sinh/chỉnh code, tạo test, phân tích lỗi, viết tài liệu hoặc tạo asset có ảnh hưởng đáng kể tới sản phẩm.

## Nội dung bắt buộc

1. Ngày và người thực hiện.
2. Mục tiêu dùng AI.
3. Công cụ/model (nếu biết).
4. Tóm tắt yêu cầu; không bắt buộc chép prompt nguyên văn.
5. Kết quả và file bị tác động.
6. Quyết định do con người xác nhận.
7. Nội dung bị sửa, loại bỏ hoặc không sử dụng.
8. Cách kiểm chứng kết quả.
9. Rủi ro hoặc việc còn lại.

Sao chép [TEMPLATE.md](TEMPLATE.md) và đặt tên `YYYY-MM-DD-noi-dung-ngan.md`. Nếu entry tổng hợp lại hoạt động trước đây, phải ghi rõ **retrospective summary** và không dựng lại prompt như thể đó là bản ghi nguyên gốc.

## Quy tắc an toàn

- Không ghi API key, token, mật khẩu, connection string hoặc thông tin xác thực.
- Không đưa sao kê thật, dữ liệu tài chính, thông tin định danh hoặc nội dung nhạy cảm vào log/prompt.
- Chỉ dùng dữ liệu tổng hợp hoặc đã được phê duyệt rõ ràng cho dự án.
- Không xem đầu ra AI là bằng chứng đã đúng; người thực hiện phải review và ghi cách kiểm chứng.
- Không ghi tên/model hoặc nội dung prompt cũ nếu không có bằng chứng; dùng mô tả trung thực ở mức tóm tắt.

## Danh mục

- [15/11/2026 — Lập kế hoạch và tạo artifact G1](2026-11-15-project-planning.md)
