# StatementReader — IDP-13

StatementReader là ứng dụng Intelligent Document Processing hỗ trợ nhân viên ngân quỹ và kế toán chuyển sao kê ngân hàng dạng PDF hoặc ảnh scan thành bảng giao dịch chuẩn. Mỗi giao dịch được gắn với vùng bằng chứng trên tài liệu, được kiểm tra số dư chạy bằng code và phải qua quy trình duyệt trước khi xuất dữ liệu.

> Trạng thái ngày 15/11/2026: đã chốt đề tài, Brief, PRD, Wireframe/UI Flow, AI Log và kế hoạch triển khai. Phần mềm đang ở pha thiết kế, chưa có bản chạy end-to-end. Hạn dự kiến hoàn thành sản phẩm: **05/12/2026**.

## Deliverables G1

| Deliverable | Tài liệu |
|---|---|
| One-page Brief | [01_ONE_PAGE_BRIEF.md](docs/submission/01_ONE_PAGE_BRIEF.md) |
| Product Requirements Document | [02_PRD.md](docs/submission/02_PRD.md) |
| Wireframe và UI Flow | [03_UI_FLOW.md](docs/submission/03_UI_FLOW.md) |
| Wireframe PNG | [wireframe-overview.png](docs/submission/assets/wireframe-overview.png) |
| UI Flow PNG | [ui-flow.png](docs/submission/assets/ui-flow.png) |
| AI Log | [Hướng dẫn và danh sách log](docs/ai-log/README.md) |

## Tổng quan sản phẩm

- **Người dùng:** Treasury Operator (nhân viên ngân quỹ) và Accountant/Approver (kế toán hoặc người phê duyệt).
- **Đầu vào:** PDF có text layer, PDF scan, PNG/JPEG và tài liệu nhiều trang trong phạm vi hỗ trợ.
- **Đầu ra:** bảng giao dịch gồm ngày, mô tả, ghi nợ, ghi có và số dư; kèm evidence, trạng thái kiểm tra và lịch sử duyệt.
- **MVP:** upload, xử lý, review hai cột, sửa và kiểm tra lại, phê duyệt, xuất CSV/XLSX/JSON.
- **Nguyên tắc:** không tự điền số không có bằng chứng; không bỏ qua trang hoặc dòng lỗi một cách im lặng; kết quả chính thức phải qua người phê duyệt.

## Nhóm

Nhóm gồm ba thành viên:

- 01 Business Analyst: yêu cầu nghiệp vụ, dữ liệu tổng hợp, QA, usability và báo cáo.
- 02 Developers: kiến trúc, xử lý PDF/OCR, backend, frontend, đánh giá và triển khai.

Tên và thông tin liên hệ của thành viên sẽ được quản lý trên trang nhóm của khóa học; repo công khai chỉ công bố khi có sự đồng thuận của từng thành viên.

## Quy tắc dữ liệu

Repo và bản demo chỉ sử dụng sao kê, tên ngân hàng, chủ tài khoản, số tài khoản và giao dịch **hoàn toàn tổng hợp**. Không commit hoặc tải lên môi trường demo:

- sao kê và số tài khoản thật;
- API key, mật khẩu hoặc file `.env`;
- dữ liệu tài chính, dữ liệu cá nhân hoặc tài liệu nội bộ;
- prompt/log chứa nội dung tài liệu nhạy cảm.

## Kế hoạch triển khai

- [Kế hoạch bàn giao đến 05/12/2026](docs/plans/IDP13_DELIVERY_PLAN.md)
- [Master plan và kiến trúc đích](docs/plans/IDP13_MASTER_PLAN.md)
- [Roadmap kỹ thuật mở rộng](docs/plans/IDP13_TASK_BACKLOG.md)

## Cách xem artifact

1. Bắt đầu với [One-page Brief](docs/submission/01_ONE_PAGE_BRIEF.md).
2. Xem yêu cầu và tiêu chí nghiệm thu trong [PRD](docs/submission/02_PRD.md).
3. Xem các màn hình và hành trình trong [Wireframe/UI Flow](docs/submission/03_UI_FLOW.md).
4. Xem cách nhóm ghi nhận việc sử dụng AI tại [AI Log](docs/ai-log/README.md).

Các file PNG trong `docs/submission/assets/` có thể xem trực tiếp trên GitHub. Nhóm có thể chỉnh sửa và tạo lại hai ảnh bằng script `tools/render_submission_assets.ps1`.

## License

Mã nguồn của repository được phân phối theo [Apache License 2.0](LICENSE). License của dataset, font, model và dependency bên thứ ba phải được kiểm tra và ghi nhận riêng trước khi đưa vào release.
