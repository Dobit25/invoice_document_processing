# Product Requirements Document — StatementReader

**Mã đề tài:** IDP-13 · **Phiên bản:** 1.0 · **Ngày:** 15/11/2026 · **Trạng thái:** Accepted 

## 1. Product vision

StatementReader giúp bộ phận ngân quỹ và kế toán biến sao kê ngân hàng không đồng nhất thành dữ liệu giao dịch có cấu trúc, có thể kiểm tra và phê duyệt. Sản phẩm hướng tới giảm thời gian nhập liệu và rà soát trong khi giữ khả năng truy nguồn cho từng giá trị tài chính.

## 2. Mục tiêu và nguyên tắc

### 2.1 Mục tiêu MVP

- Xử lý được PDF có text layer, PDF scan và ảnh trong phạm vi bố cục hỗ trợ.
- Chuẩn hóa ngày, mô tả, ghi nợ, ghi có và số dư thành bảng giao dịch.
- Cho phép người dùng truy ngược từ trường/dòng về vùng nguồn.
- Kiểm tra tính nhất quán của số dư bằng code và hiển thị ngoại lệ.
- Hoàn thành quy trình maker–checker: người vận hành sửa và gửi duyệt, kế toán phê duyệt và xuất dữ liệu.
- Đo accuracy, confident-wrong, coverage, latency và chi phí trên golden set tổng hợp.

### 2.2 Nguyên tắc sản phẩm

- Không tự điền một số tiền không tồn tại trong transcription/evidence nguồn.
- Không bỏ qua trang, dòng hoặc lỗi xử lý một cách im lặng.
- Không dùng `float` cho tiền; giá trị chuẩn hóa sử dụng Decimal.
- `validation_pass`, `confidence` và `approved` là ba khái niệm độc lập.
- Prediction gốc được giữ nguyên; chỉnh sửa của con người tạo revision có audit.
- Chỉ sử dụng dữ liệu tổng hợp trong repo, benchmark và demo công khai.

## 3. Personas và quyền

| Persona | Nhu cầu | Quyền MVP |
|---|---|---|
| Treasury Operator | Tải sao kê, theo dõi xử lý, kiểm tra và sửa giao dịch | Upload; xem tài liệu được cấp quyền; sửa/từ chối field; chạy lại validation; gửi phê duyệt |
| Accountant/Approver | Kiểm tra ngoại lệ và chịu trách nhiệm với đầu ra | Tất cả quyền xem; phê duyệt/từ chối revision; xuất CSV/XLSX/JSON đã duyệt; xem audit |

Mặc định người tạo hoặc sửa không tự phê duyệt revision của chính mình khi maker–checker được bật. Quyền phải được kiểm tra ở backend, không chỉ ẩn nút trên giao diện.

## 4. User journey

1. Người dùng đăng nhập và mở Document Inbox.
2. Treasury Operator tải PDF/ảnh hoặc chọn sample tổng hợp.
3. Hệ thống kiểm tra định dạng, kích thước và tạo processing job.
4. Từng trang được định tuyến qua parser hoặc OCR; UI hiển thị tiến trình và lỗi từng trang.
5. Hệ thống dựng các dòng giao dịch, gắn evidence và chạy validation.
6. Treasury Operator review các dòng rủi ro, sửa hoặc từ chối rồi gửi duyệt.
7. Accountant mở đúng revision, xem validation/evidence và phê duyệt hoặc trả lại.
8. Revision đã phê duyệt được xuất; hoạt động được lưu trong audit log.

## 5. User stories

| ID | User story | Giá trị |
|---|---|---|
| US-01 | Là Treasury Operator, tôi muốn đăng nhập để chỉ xem và sửa tài liệu được cấp quyền. | Bảo vệ dữ liệu và trách nhiệm thao tác |
| US-02 | Tôi muốn tải PDF hoặc ảnh và biết ngay file có được hỗ trợ không. | Tránh chờ một job không thể xử lý |
| US-03 | Tôi muốn thấy tiến trình và lỗi từng trang. | Không hiểu nhầm job lỗi là kết quả rỗng |
| US-04 | Tôi muốn nhận bảng giao dịch chuẩn từ PDF hoặc scan. | Giảm nhập liệu thủ công |
| US-05 | Tôi muốn nhấp vào field để thấy đúng vùng nguồn. | Kiểm tra nhanh và tăng niềm tin |
| US-06 | Tôi muốn biết dòng nào làm số dư chạy bị lệch. | Tập trung xử lý ngoại lệ |
| US-07 | Tôi muốn sửa một giá trị và hệ thống kiểm tra lại. | Bảo đảm revision nhất quán |
| US-08 | Tôi muốn gửi revision cho Accountant phê duyệt. | Thực thi maker–checker |
| US-09 | Là Accountant, tôi muốn phê duyệt hoặc trả lại đúng revision. | Tránh duyệt nhầm dữ liệu cũ |
| US-10 | Tôi muốn xuất dữ liệu đã duyệt ở định dạng phù hợp. | Sẵn sàng cho bước đối chiếu tiếp theo |
| US-11 | Tôi muốn xem ai đã sửa, duyệt hoặc xuất dữ liệu. | Audit và truy trách nhiệm |
| US-12 | Là nhóm phát triển, tôi muốn đo accuracy/latency/cost có cỡ mẫu. | Đánh giá trung thực chất lượng sản phẩm |

## 6. Functional requirements

### 6.1 Truy cập và tài liệu

| ID | Yêu cầu | Ưu tiên | Acceptance criteria |
|---|---|---|---|
| FR-01 | Đăng nhập và phân quyền hai vai trò | MVP | Sai thông tin đăng nhập bị từ chối; endpoint tài liệu/review/export trả 401/403 khi không đủ quyền; session hết hạn theo cấu hình |
| FR-02 | Upload PDF, PNG, JPEG và chọn sample | MVP | Kiểm tra extension, MIME thực tế, dung lượng, số trang/pixel; file không hợp lệ có mã lỗi và hướng dẫn; tên lưu trữ do hệ thống sinh |
| FR-03 | Document Inbox và lịch sử | MVP | Hiển thị tài liệu, người tạo, thời gian, trạng thái job/review và revision hiện tại; refresh không làm mất trạng thái |
| FR-04 | Private file access | MVP | Tài liệu/render/export không nằm trong static public folder; backend kiểm tra quyền theo object trước khi trả nội dung |

### 6.2 Xử lý tài liệu

| ID | Yêu cầu | Ưu tiên | Acceptance criteria |
|---|---|---|---|
| FR-05 | Tạo job và theo dõi tiến trình | MVP | Upload trả job ID; trạng thái gồm queued/running/succeeded/partial_failed/failed/cancelled; có stage, trang hiện tại và lỗi; retry không nhân đôi giao dịch |
| FR-06 | Đường xử lý PDF text layer | MVP | Lấy token, raw text, page và bbox; giữ source order; nếu text layer không đủ chất lượng thì chuyển OCR hoặc review theo policy |
| FR-07 | Đường xử lý scan/mixed document | MVP | PDF scan/PNG/JPEG được OCR; mixed PDF định tuyến theo trang; OCR lỗi một trang tạo partial failure và không làm mất dấu trang |
| FR-08 | Chuẩn hóa row schema | MVP | Mỗi transaction có stable ID, thứ tự nguồn, ngày, mô tả, debit, credit, balance và currency; missing khác zero; tiền không lưu bằng float |
| FR-09 | Xử lý nhiều trang và row kinds | MVP | Header/footer lặp, multiline description và carry-forward được phân biệt khỏi transaction; không tự loại hai giao dịch giống nhau |
| FR-10 | Template theo cấu hình | MVP giới hạn | Ba họ bố cục được hỗ trợ bằng config có version; unknown layout được fallback hoặc đưa review, không báo thành công giả |

### 6.3 Evidence, confidence và validation

| ID | Yêu cầu | Ưu tiên | Acceptance criteria |
|---|---|---|---|
| FR-11 | Evidence theo field/dòng | MVP | Field tự động chấp nhận có page và một hoặc nhiều bbox; click field đưa UI tới đúng vùng khi zoom/rotate; thiếu evidence được gắn cờ |
| FR-12 | Confidence có provenance | MVP | Confidence cho biết phiên bản policy/model; không dùng điểm LLM tự khai là xác suất đúng; nhóm chưa đủ dữ liệu hiệu chuẩn hiển thị rõ trạng thái đó |
| FR-13 | Running-balance validation | MVP | Dùng Decimal và quy ước template để kiểm tra từng dòng; hiển thị expected/observed và boundary lệch đầu tiên; không tự sửa số để phương trình khớp |
| FR-14 | Kiểm tra completeness và ngày | MVP | Phát hiện trang xử lý lỗi, row candidate chưa map, số dư đầu/cuối thiếu và ngày không hợp lệ; balance-pass không xóa các cảnh báo này |
| FR-15 | Phân biệt source error và extraction error | MVP | Sao kê tổng hợp được cài sai số dư tạo issue nguồn riêng; hệ thống không tuyên bố extraction sai nếu giá trị đã sao chép đúng nguồn |

### 6.4 Review, approval và export

| ID | Yêu cầu | Ưu tiên | Acceptance criteria |
|---|---|---|---|
| FR-16 | Review workbench hai cột | MVP | Tài liệu bên trái, bảng bên phải; lọc/nhảy qua issue; có trạng thái loading, empty, partial, unsupported và approved |
| FR-17 | Sửa, từ chối và revalidate | MVP | Mỗi edit lưu before/after, actor, time, reason và provenance; validation chạy trên revision mới; conflict giữa hai tab không ghi đè âm thầm |
| FR-18 | Submit và approval workflow | MVP | Operator gửi revision; Accountant approve/reject; blocking issue chưa xử lý chặn approval; edit sau approval làm approval cũ mất hiệu lực |
| FR-19 | Export | MVP | Chỉ Accountant xuất approved revision chính thức; CSV/XLSX/JSON giữ row count, Decimal/date và revision metadata; chống spreadsheet formula injection |
| FR-20 | Audit trail | MVP | Log upload, xử lý, edit, submit, approve/reject và export; không lưu raw document/prompt trong application log mặc định |

### 6.5 Đánh giá và vận hành

| ID | Yêu cầu | Ưu tiên | Acceptance criteria |
|---|---|---|---|
| FR-21 | Dataset tổng hợp và split | MVP | Dev/calibration/golden tách theo statement family/seed; biến thể PDF/scan của cùng statement không qua split; manifest có checksum |
| FR-22 | Báo cáo chất lượng | MVP | Báo cáo theo field/row/document và loại đầu vào; có n, missing/extra rows, confident-wrong, coverage, validation pass và failures; pre/post-HITL tách biệt |
| FR-23 | Báo cáo latency và cost | MVP | P50/P95 theo route và page count; usage API gồm retry; giá chưa biết hiển thị unpriced; thông số máy/model/config được ghi |
| FR-24 | Template onboarding | Nâng cao | Thêm layout thứ tư bằng config trong timebox, kiểm thử held-out và regression ba layout cũ; nếu không đạt ghi limitation |

## 7. Non-functional requirements

| ID | Nhóm | Yêu cầu và tiêu chí nghiệm thu |
|---|---|---|
| NFR-01 | Accuracy | Metric được định nghĩa trước benchmark; số liệu có n và split; không loại failure khỏi denominator |
| NFR-02 | Performance | Mục tiêu ban đầu cho tài liệu 1–5 trang: PDF P95 ≤5 giây, scan P95 ≤30 giây; đây là target cần đo, không phải kết quả cam kết |
| NFR-03 | Reliability | Job idempotent; worker restart có recovery; lỗi provider/file/page không tạo success rỗng; revision đã duyệt bất biến |
| NFR-04 | Security | Secret chỉ ở backend; private storage; least privilege; giới hạn upload; log không chứa payload; public demo dùng sample tổng hợp |
| NFR-05 | Privacy | Repo/demo chỉ dùng dữ liệu tổng hợp; không gửi sao kê thật tới API trong phạm vi dự án; có retention/TTL cho upload và render |
| NFR-06 | Usability | Tối thiểu 5 người thử nếu tuyển đủ; đo completion time, error và feedback; tác vụ chính dùng được bằng bàn phím và không chỉ dựa vào màu |
| NFR-07 | Reproducibility | Có lockfiles, seed, dataset/config/model version; clone sạch chạy được bằng hướng dẫn; benchmark tạo JSON/Markdown có hash |
| NFR-08 | Maintainability | PDF/OCR/LLM qua adapter; schema có version; template nằm ngoài source logic; test tập trung ở tiền, row, evidence, quyền và workflow |
| NFR-09 | Cost | Ngân sách API cơ sở 12 USD, chỉ dùng thêm tối đa 5 USD sau quyết định nhóm; retry và output token có giới hạn |
| NFR-10 | Licensing | Ghi nguồn và license của code, weights, font, binary và dataset; Apache-2.0 của repo không tự động bao phủ dependency |

## 8. Metrics và acceptance cấp sản phẩm

| Metric | Cách đọc |
|---|---|
| Numeric/date exact accuracy | Đúng tuyệt đối sau canonical normalization; missing được tính lỗi |
| Transaction-row precision/recall/F1 | Đo dòng thừa, dòng thiếu và dòng ghép sai; không dựa riêng vào tổng số dư |
| Whole-statement exact match | Tất cả core fields và row đều đúng trước HITL |
| Evidence coverage/IoU | Tỷ lệ field có vùng nguồn và độ khớp vùng trên subset có nhãn bbox |
| Confident-wrong và coverage | Luôn báo cùng nhau, có denominator và giới hạn thống kê |
| Ledger consistency | Tách sao kê nguồn hợp lệ và nguồn cài lỗi |
| P50/P95 latency | Tách PDF/scan, cold/warm, queue wait và số trang |
| Cost | API usage thực tế/trang; tách unpriced và local compute estimate |
| Task success | Tỷ lệ người thử hoàn thành upload → review → approval → export và thời gian hoàn thành |

Golden set MVP dự kiến 60 sao kê tổng hợp; cỡ mẫu này chưa đủ chứng minh một tỷ lệ lỗi cực thấp. Nếu bằng chứng hiệu chuẩn không đủ, sản phẩm tiếp tục yêu cầu human approval và báo rõ limitation.

## 9. Phạm vi phát hành

### MVP bắt buộc

FR-01 đến FR-23 trong phạm vi ba bố cục, VND, PDF/scan/mixed và dữ liệu tổng hợp; sáu màn hình trong UI flow; benchmark và tài liệu bàn giao.

### Nâng cao nếu còn thời gian

FR-24; gợi ý dòng nghi ngờ nâng cao; keyboard polish; dashboard chất lượng nhỏ; so sánh thêm một model/provider nếu không ảnh hưởng release.

### Out of scope

Đối chiếu với sổ cái; hạch toán; chuyển tiền; Internet Banking; fraud/AML; chữ viết tay; nhiều tiền tệ trong cùng ledger; mobile app; multi-tenant/SSO; tự động học từ correction; production SLA và xử lý dữ liệu thật.

## 10. Milestones

| Mốc | Kết quả dự kiến |
|---|---|
| 15/11/2026 | Chốt Brief, PRD, Wireframe/UI Flow, GitHub và AI Log |
| 20/11/2026 | Token schema chung; PDF/scan baseline; generator và UI mock |
| 27/11/2026 | Upload → review → submit → approve → export chạy E2E; feature freeze |
| 02/12/2026 | Release candidate, security/failure checks và final benchmark |
| 04/12/2026 | Rehearsal, video dự phòng và đóng gói |
| 05/12/2026 | Nộp sản phẩm |

## 11. Bảng truy vết User Story → Functional Requirement

| User story | Functional requirements |
|---|---|
| US-01 | FR-01, FR-04, FR-20 |
| US-02 | FR-02, FR-03 |
| US-03 | FR-05, FR-07, FR-14 |
| US-04 | FR-06, FR-07, FR-08, FR-09, FR-10 |
| US-05 | FR-11, FR-16 |
| US-06 | FR-13, FR-14, FR-15, FR-16 |
| US-07 | FR-12, FR-17 |
| US-08 | FR-18, FR-20 |
| US-09 | FR-17, FR-18, FR-20 |
| US-10 | FR-19 |
| US-11 | FR-20 |
| US-12 | FR-21, FR-22, FR-23, FR-24 |
