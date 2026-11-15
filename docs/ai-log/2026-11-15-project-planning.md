# AI Log — Lập kế hoạch và tạo artifact G1

**Ngày:** 2026-11-15  
**Người thực hiện:** Tùng 
**Loại bản ghi:** Retrospective summary cho giai đoạn nghiên cứu/lập kế hoạch; contemporaneous cho bộ artifact G1  
**Trạng thái:** Hoàn thành

## Mục tiêu và bối cảnh

AI được dùng để hỗ trợ tư vấn tổ chức phạm vi IDP-13 thành bộ deliverable có thể review: one-page brief, PRD, UI flow/wireframe, cấu trúc repo và cơ chế AI log. Phần retrospective chỉ tóm tắt quá trình lên ý tưởng trước đó.

## Công cụ/model

- Công cụ: OpenAI Codex
- Model trong phiên tạo artifact hiện tại: GPT-5.6 Sol

## Tóm tắt yêu cầu gửi AI

- Đánh giá phạm vi đề tài IDP-13 và lập kế hoạch khả thi cho nhóm ba người.
- Tư vấn thiết kế sản phẩm độc lập cho nhân viên ngân quỹ và kế toán, xử lý đồng thời PDF có text và scan.
- Ưu tiên accuracy, evidence, kiểm tra số dư, human approval, hiệu năng và UI/UX.
- Chỉ sử dụng dữ liệu tổng hợp; không đưa tài liệu tài chính thật hoặc bí mật vào artifact/log.
- Chuẩn hóa deliverable G1 và bảo đảm chúng có thể xem trực tiếp trong GitHub.

## Kết quả và file bị tác động

- `README.md`, `.gitignore`
- `docs/submission/01_ONE_PAGE_BRIEF.md`
- `docs/submission/02_PRD.md`
- `docs/submission/03_UI_FLOW.md`
- `docs/submission/assets/wireframe-overview.png`
- `docs/submission/assets/ui-flow.png`
- `docs/ai-log/README.md`, `docs/ai-log/TEMPLATE.md` và entry này
- `.github/pull_request_template.md`

## Quyết định do con người xác nhận

- Chọn đề tài IDP-13 và xây dựng StatementReader như một sản phẩm độc lập.
- Nhóm có ba thành viên: một người mạnh BA và hai người có khả năng code/kiến trúc.
- Thời gian dự kiến 15 giờ/người/tuần; hạn hoàn thiện sản phẩm 05/12/2026.
- PDF có text và scan được phát triển song song từ đầu.
- Repo và demo chỉ dùng dữ liệu tổng hợp; mọi approval cuối cùng thuộc về con người.

Nhóm cần bổ sung tên người xác nhận và chốt các câu hỏi mở trong PRD trước khi coi entry là Accepted.

## Nội dung đã sửa, loại bỏ hoặc không sử dụng

- Không đưa API key, sao kê thật, dữ liệu cá nhân hoặc dữ liệu tài chính vào repo.
- Các target accuracy/latency được ghi là tiêu chí nghiệm thu, chưa được trình bày như kết quả đã đạt.

## Cách kiểm chứng

- Review chéo Brief, PRD và UI Flow để kiểm tra persona, scope, quyền và trạng thái nhất quán.
- Kiểm tra toàn bộ link nội bộ trong root README và khả năng mở trực tiếp hai ảnh PNG.
- Kiểm tra bảng truy vết user story → functional requirement và acceptance criteria của từng yêu cầu.
- Chạy benchmark trên golden set tổng hợp và test E2E ở build phase; kết quả sẽ được ghi ở entry riêng.

## Rủi ro còn lại / bước tiếp theo

- Artifact hiện tại là thiết kế, chưa chứng minh accuracy, latency hay độ an toàn của bản triển khai.
- Tên thành viên, lựa chọn OCR/provider, giới hạn file và yêu cầu public deployment chưa được chốt.
- Wireframe cần usability test và có thể thay đổi sau phản hồi mentor/người dùng.

## Xác nhận review

**Người review:** Tùng 
**Ngày review:** 15/11/2026  
**Kết luận:** Accepted
