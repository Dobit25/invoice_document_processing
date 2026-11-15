# One-page Brief — StatementReader (IDP-13)

**Phiên bản:** 1.0 · **Ngày:** 15/11/2026 · **Hạn dự kiến hoàn thành:** 05/12/2026 · **Nhóm:** T146

## Bài toán

Nhân viên ngân quỹ và kế toán nhận sao kê từ nhiều ngân hàng dưới dạng PDF có text layer, PDF scan hoặc ảnh. Mỗi ngân hàng có bố cục, tên cột và quy ước khác nhau; mô tả giao dịch có thể xuống nhiều dòng, header lặp lại ở mỗi trang và số dư được chuyển tiếp giữa các trang. Việc nhập lại bằng tay chậm, dễ bỏ sót giao dịch hoặc sai một chữ số, làm tăng thời gian đối chiếu và kiểm tra.

## Người dùng và pain points

**Treasury Operator** tải tài liệu, kiểm tra dữ liệu được trích xuất và sửa các dòng bất thường. **Accountant/Approver** kiểm tra kết quả cuối, phê duyệt và xuất dữ liệu.

Các pain point chính:

- nhập tay một bảng giao dịch dài và nhiều trang;
- khó phát hiện một dòng bị mất, nhân đôi hoặc đọc sai số;
- phải dò lại toàn bộ tài liệu khi hệ thống không chỉ ra nguồn;
- không biết kết quả nào đủ tin cậy và kết quả nào cần kiểm tra;
- mỗi bố cục mới thường làm quy trình tự động hóa bị gián đoạn.

## Giải pháp

StatementReader nhận sao kê PDF hoặc ảnh scan và tạo bảng giao dịch chuẩn gồm ngày, mô tả, ghi nợ, ghi có và số dư. Mỗi giá trị được liên kết với vùng bằng chứng trên trang gốc. Hệ thống kiểm tra số dư đầu kỳ, số dư chạy và số dư cuối kỳ bằng code; các trang, dòng hoặc trường không chắc chắn được đưa vào hàng đợi review. Người dùng sửa trên màn hình hai cột, hệ thống kiểm tra lại, sau đó Accountant phê duyệt trước khi xuất CSV, XLSX hoặc JSON.

## Đầu vào và đầu ra

**Đầu vào MVP:** PDF text layer, PDF scan, PNG/JPEG; tài liệu một hoặc nhiều trang, VND và các bố cục tổng hợp nằm trong phạm vi đã công bố.

**Đầu ra MVP:** bảng giao dịch chuẩn; evidence theo trường/dòng; lỗi validation; trạng thái review; revision đã phê duyệt; file xuất có metadata phiên bản.

## Phạm vi MVP

- đăng nhập với hai vai trò và phân quyền phía server;
- upload, kiểm tra file, theo dõi tiến trình và xem lịch sử;
- xử lý đồng thời nhánh PDF text và nhánh OCR cho scan/mixed document;
- review workbench gồm tài liệu bên trái và bảng giao dịch bên phải;
- sửa, từ chối, gửi duyệt, phê duyệt và xuất kết quả;
- audit trail tối thiểu và không trả kết quả rỗng một cách im lặng;
- benchmark trên dữ liệu sao kê hoàn toàn tổng hợp.

Không nằm trong MVP: đối chiếu sổ cái, hạch toán, chuyển tiền, kết nối Internet Banking, phát hiện gian lận, chữ viết tay và triển khai production với dữ liệu thật.

## Điểm khác biệt

1. **Evidence-first:** người duyệt nhấp vào giao dịch để tới đúng trang và vùng nguồn.
2. **Deterministic validation:** số dư được kiểm tra bằng `Decimal` và quy tắc nghiệp vụ, không giao phép tính cho mô hình.
3. **Human approval:** kết quả có lỗi hoặc thiếu bằng chứng không tự động trở thành dữ liệu chính thức.
4. **Đo được chất lượng:** báo cáo theo trường, dòng, tài liệu, độ phủ, confident-wrong, thời gian và chi phí.

## Chỉ số thành công

- field accuracy và transaction-row precision/recall/F1, kèm cỡ mẫu;
- tỷ lệ sao kê hợp lệ vượt kiểm tra số dư và tỷ lệ nguồn lỗi bị phát hiện;
- 100% trường số được tự động chấp nhận có evidence;
- confident-wrong được báo cáo cùng coverage và giới hạn thống kê;
- P50/P95 latency theo PDF và scan, chi phí thực tế trên mỗi trang;
- người thử hoàn thành upload → review → approval → export, ghi nhận thời gian và lỗi thao tác.

Các ngưỡng accuracy/latency trong kế hoạch là mục tiêu; chỉ được công bố là kết quả sau benchmark.

## Rủi ro và giả định

- Dữ liệu tổng hợp không đại diện đầy đủ cho sao kê thật; sản phẩm chưa chứng minh production accuracy.
- OCR giảm chất lượng ở ảnh mờ, xoay, crop hoặc chữ nhỏ; hệ thống phải báo unreadable/needs review.
- Số dư khớp chưa chứng minh mọi giao dịch đều đúng; vẫn cần row completeness và evidence.
- API cloud chỉ được dùng với dữ liệu tổng hợp trong bản nộp; dữ liệu thật cần quyền xử lý và chính sách riêng.
- Với ba thành viên và thời gian đến 05/12, nhóm ưu tiên luồng E2E ổn định, ba họ bố cục và chất lượng review trước tính năng mở rộng.
