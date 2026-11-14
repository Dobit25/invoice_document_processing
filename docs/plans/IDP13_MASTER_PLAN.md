# IDP-13 — Kế hoạch xây dựng StatementReader

Trạng thái: kiến trúc đích và danh mục kỹ thuật toàn sản phẩm. **Kế hoạch thực thi có hiệu lực cho hạn 05/12/2026 là [IDP13_DELIVERY_PLAN.md](IDP13_DELIVERY_PLAN.md)**; khi có khác biệt về scope, stack, số layout, golden size, owner hoặc effort, delivery plan được ưu tiên. Không thực hiện toàn bộ roadmap dưới đây trong ba tuần. Các đường dẫn mã nguồn là cấu trúc dự kiến, chưa phải tính năng đã được xây dựng.

## 1. Kết quả cần bàn giao

Một ứng dụng web giúp nhân viên ngân quỹ và kế toán tải sao kê PDF/ảnh, nhận bảng giao dịch chuẩn, kiểm tra bằng chứng tại từng dòng, xử lý ngoại lệ và xuất dữ liệu đã duyệt. Hệ thống kiểm tra số dư bằng code và thể hiện rõ chất lượng, thời gian, chi phí xử lý.

Luồng hoàn chỉnh: đăng nhập → tải tài liệu → xem tiến trình → xem giao dịch và vùng nguồn → sửa/duyệt ngoại lệ → kiểm tra lại → phê duyệt → xuất CSV/XLSX/JSON → tra cứu lịch sử.

Yêu cầu gốc từ `de-tai-cohort-v-20261114.xlsx`, IDP-13:

- PDF có text layer và ảnh/scan; mô tả ngắt dòng, header lặp, số dư chuyển trang, nhiều định dạng số, nhiều trang.
- Trường chuẩn: ngày, mô tả, ghi nợ, ghi có, số dư; bằng chứng vị trí và độ tin cậy từng dòng.
- Kiểm tra số dư chạy, số dư đầu/cuối, dấu ghi nợ/ghi có, thứ tự ngày bằng code.
- Không để mô hình tự điền số; không bỏ sót giao dịch một cách im lặng.
- Chỉ sử dụng sao kê và thông tin tài khoản hoàn toàn tổng hợp.
- Golden set 50–150 sao kê có ca khó, báo cáo theo trường/dòng kèm n, confident-wrong, tỷ lệ qua kiểm tra số dư, USD/trang.
- Màn hình duyệt và ít nhất hai vai trò; một lệnh xử lý end-to-end trên bản clone sạch.
- Nâng cao: khoanh vùng dòng nghi ngờ, thêm template không sửa code, router, xuất dữ liệu và chi phí theo tháng.

Ngoài phạm vi bản nộp: đối chiếu sổ cái, hạch toán, chuyển tiền, kết nối Internet Banking, phát hiện gian lận, đào tạo OCR mới, nhiều loại chứng từ, hệ thống quản lý tài chính đầy đủ.

## 2. Những quyết định cần chốt

| Quyết định | Mặc định để lập kế hoạch | Tác động nếu khác |
|---|---|---|
| Nhân lực và thời gian | Đã chốt: 2 developer + 1 BA, mỗi người 15h/tuần, hạn 05/12/2026 | Khoảng 90 giờ coding + 45 giờ BA trong ba tuần |
| Thứ tự triển khai | Đã chốt: PDF và scan song song ngay tuần đầu | Developer 1 PDF/domain; developer 2 scan/UI |
| API | Đã chốt: OpenAI 12 USD, có thể lên 17 USD; có quota hằng ngày cần xác nhận data sharing | Chỉ synthetic ở bản nộp; không suy ra quyền gửi dữ liệu thật |
| Sản phẩm | Web desktop, tiếng Việt, single organization | Multi-tenant/SSO là nhánh pilot sau bản nộp |
| Tiền tệ | VND trước; Decimal, cấu hình số lẻ theo tiền tệ | Không xử lý nhiều tiền tệ trong cùng ledger ở MVP |
| Quy mô tài liệu | Đề xuất tối đa 20 MB, 30 trang/tài liệu | Chốt lại sau đo baseline, ghi giới hạn trên UI |
| Tính năng phê duyệt | Treasury operator tạo/sửa; accountant phê duyệt/xuất bản đã duyệt | UI và API phải cùng thực thi policy |
| Dữ liệu | Bản nộp: 60 golden + 30 dev + 30 calibration; đích dài hạn 150 golden | Không xem golden nhỏ là đủ chứng minh risk rất thấp |

Không cam kết accuracy, P95 hoặc chi phí trước baseline. Các con số trong kế hoạch là mục tiêu nghiệm thu đề xuất, không phải kết quả thực nghiệm hay tiêu chí do ban tổ chức công bố.

## 3. Ba phương án kỹ thuật

| Phương án | Cách xây dựng | Điểm mạnh | Chi phí/rủi ro | Chọn khi |
|---|---|---|---|---|
| A — Hybrid có bằng chứng (khuyến nghị) | Parser PDF + OCR giữ tọa độ; luật bảng; LLM chọn token/row mapping ở ca khó; validator độc lập | Kiểm soát số liệu, dễ truy nguồn, đường PDF nhanh, ít lệ thuộc API | Cần đầu tư row reconstruction, tọa độ và tập kiểm thử | Muốn accuracy, UX và product hoàn chỉnh |
| B — VLM chủ đạo | Render trang → VLM tìm bảng và giá trị; OCR/token alignment xác minh lại số và vùng nguồn | Ra baseline thị giác nhanh, linh hoạt bố cục | API latency/cost, sai số và khó align; VLM output không có evidence không được tự qua | Thời gian rất ngắn hoặc nhiều layout khó |
| C — Local-first | Parser + OCR chạy local + luật; model ngôn ngữ local tùy tài nguyên | Chủ động luồng dữ liệu, có thể chạy không Internet | Cài đặt/inference/model license; GPU nếu dùng VLM local; chất lượng tiếng Việt cần đo | Có yêu cầu local-only hoặc ngân sách API thấp |

Chọn A làm kiến trúc; B là baseline so sánh và fallback có kiểm soát, C là cấu hình triển khai bằng adapter, không triển khai ba hệ thống riêng. Timebox nghiên cứu parser/OCR/provider 2–3 ngày công, dùng cùng dev set, chọn bằng chất lượng/latency/cost và khả năng giữ tọa độ. Không chọn model theo quảng cáo hoặc chỉ nhìn demo tốt.

### Stack đích sau bản nộp

Bản nộp dùng SQLite + một DB-backed worker để giảm thời gian vận hành; không xây PostgreSQL/Celery/Redis trong ba tuần. Các lựa chọn dưới đây là hướng mở rộng sau deadline, không là dependencies bắt buộc của bản nộp.

- Backend: Python 3.12, FastAPI, Pydantic, SQLAlchemy/Alembic, PostgreSQL.
- PDF: pdfplumber lấy token/tọa độ; pypdfium2 render; adapter để thay parser khi có benchmark.
- OCR: benchmark một backend local (PaddleOCR hoặc Tesseract) và một backend API nếu được phép; chỉ giữ backend thắng và adapter mock trong release đầu.
- Frontend: React + TypeScript + Vite, PDF.js, thư viện bảng có virtualization, UI components thống nhất. Không cần Next.js nếu không có nhu cầu SSR.
- Jobs: Celery + Redis, worker riêng, trạng thái job được lưu PostgreSQL; polling trước, SSE tùy chọn. Job phải idempotent, retry có giới hạn.
- File store: local private volume cho demo single host, abstraction để thêm S3-compatible store ở pilot. Không cần MinIO riêng trong bản nộp đầu.
- Generator: ReportLab + Faker + Pillow/OpenCV; font tiếng Việt có license được lưu nguồn.
- Test: pytest, frontend component tests ở logic tương tác quan trọng, Playwright cho hành trình end-to-end, load test cho worker/API.
- Release: Docker Compose, lockfiles, CI; không cần Kubernetes, vector DB hoặc agent framework cho đường xử lý chính.

pdfplumber có giấy phép MIT. pypdfium2 có Apache-2.0/BSD-3-Clause, nhưng binary PDFium và thư viện đi kèm vẫn cần notice tương ứng. PyMuPDF có lựa chọn AGPL/commercial; nếu muốn dùng cần quyết định giấy phép riêng, không mặc định coi Apache-2.0 của repo bao phủ dependency. License của OCR code và weights phải kiểm tra tách biệt.

## 4. Kiến trúc và hợp đồng dữ liệu

```text
Browser → FastAPI → PostgreSQL + private file store
                    ↓ job ID
                 Redis → Worker
                          ↓
             kiểm tra file / inspect / render
                          ↓
             router theo từng trang, đo bằng code
                   ↙                  ↘
             PDF tokens             OCR tokens
                   ↘                  ↙
                 token representation chung
                          ↓
             template / row reconstruction
                          ↓ nếu cần
            LLM chọn token IDs / mapping schema
                          ↓
          copy token → parse Decimal/date → evidence
                          ↓
             validator → calibration → review API
                          ↓
                 sửa → revalidate → approve → export
```

### Contract bắt buộc trước khi phát triển song song

- `SourceToken`: token_id, page_index, raw_text, bbox chuẩn hóa, extractor, OCR score nếu có, transform ảnh gốc↔ảnh tiền xử lý.
- `FieldValue`: raw_text, normalized_value, source_token_ids[], evidence_regions[], source_kind, issues[], confidence nullable, extraction_version. Giá trị người sửa có provenance riêng; không giả mạo là đọc từ nguồn.
- `Transaction`: stable row_id, source_order, transaction_date, value_date tùy chọn, description, debit, credit, balance, currency, evidence, review_state. Không dùng số float cho tiền; JSON tiền là chuỗi decimal.
- `Statement`: opening/closing balance có nguồn riêng, account synthetic, kỳ sao kê, layout/template version, transactions, document hash, pipeline version, page coverage, run cost.
- `ValidationIssue`: rule_id, severity, row_ids, expected/observed, actionable message. Không sửa số để làm phương trình khớp.
- `PredictionSnapshot`: bất biến sau mỗi run; `ReviewRevision`: lớp sửa của người dùng; `ApprovedRevision`: snapshot xuất bản. Benchmark luôn dùng prediction trước người sửa.
- `Job`: queued/running/succeeded/partial_failed/failed/cancelled. Partial output hiển thị rõ, không coi là hoàn thành sao kê.
- `Review`: needs_review/in_review/ready_for_approval/approved/rejected. `validation_pass` độc lập với trạng thái duyệt và `extraction_correct`.

Tọa độ thống nhất: gốc trên-trái, [0,1], page width/height và rotation lưu rõ; nhiều vùng cho mô tả ngắt dòng/qua trang. UI dùng transform PDF.js, không nhân tọa độ bằng hệ số tùy ý.

### Quy tắc nghiệp vụ cần viết trước

`balance[i] = balance[i-1] + credit[i] - debit[i]` theo quy ước ledger đã chọn. Không suy đoán cùng quy ước cho mọi ngân hàng: template định nghĩa ascending/descending, debit/credit hoặc signed amount, currency precision và số dư trước/sau giao dịch. Giữ thứ tự nguồn khi nhiều giao dịch cùng ngày; không sort chỉ theo ngày.

Ô thiếu khác số 0; ngày giao dịch khác ngày giá trị. Header, subtotal, brought-forward/carried-forward không phải transaction. Kỳ sao kê có thể khác posting date; cần cấu hình, không loại bỏ giao dịch chỉ vì ngày khác kỳ. Không tự loại dòng trùng: hai giao dịch giống nhau có thể đều hợp lệ.

Số dư khớp là một phép kiểm tra tính nhất quán. Nó có thể bỏ lọt cặp giao dịch bù nhau, mô tả sai, giao dịch đúng tổng nhưng sai ngày, hoặc đầu/cuối cùng sai. Vì vậy phải có row completeness, evidence và exact-match evaluation độc lập.

## 5. Chiến lược dữ liệu và nghiệm thu

### Split và khả năng tái lập

- Dev: tối thiểu 80 tài liệu để dựng parser/template/prompt và thử lỗi.
- Calibration: tối thiểu 60 tài liệu khác để chọn ngưỡng; tăng theo số nhóm nếu score chưa đủ dữ liệu. Dành một phần kiểm định nội bộ cho calibrator; không dùng golden để chọn ngưỡng.
- Golden: 150 sao kê frozen, mục tiêu 6 họ bố cục × 25 tài liệu; phân bố PDF/scan/mixed được ghi trước khi sinh. Trong đó có ít nhất hai họ bố cục không dùng ở dev/calibration để đánh giá transfer. Không ngầm hứa mọi layout mới đều tự động đạt cùng accuracy.
- Tách theo statement_id/family/seed: các bản clean/blur/scan của cùng sao kê thuộc cùng split. Ground truth chỉ evaluator được đọc; worker không truy cập nhãn.
- Sau lỗi golden, ghi vào báo cáo; không chỉnh rồi báo lại cùng bộ như final test mới. Vòng phát hành sau tạo test độc lập hoặc ghi rõ test đã dùng để phát triển.
- Có subset ảnh in/chụp lại từ tài liệu tổng hợp nếu thời gian cho phép. Chỉ degradation bằng phần mềm chưa đại diện đầy đủ camera thật.

### Ma trận ca khó

Clean PDF; text order sai; Unicode tiếng Việt; bảng có/không đường kẻ; mô tả nhiều dòng; bảng qua trang; header/footer lặp; số dư chuyển trang; ascending/descending; cùng ngày nhiều giao dịch; dấu âm/ngoặc; dấu chấm/phẩy; empty vs zero; reversal/fee/interest; một tài liệu không có giao dịch; scan blur/skew/90°/180°; mixed PDF; thiếu trang; số dư nguồn tự mâu thuẫn; cặp giao dịch bù nhau bị bỏ; dòng trùng thật; crop làm mất chữ số; file hỏng/encrypted/oversized. Chữ viết tay và nhiều tiền tệ trong một sao kê là ngoài MVP, trả rõ unsupported nếu gặp.

### Metric và mục tiêu đề xuất

| Chỉ số | Cách đo | Mục tiêu để lập kế hoạch |
|---|---|---|
| Numeric/date exact accuracy | Theo từng trường sau canonical normalization; báo cáo cả field thiếu | PDF sạch ≥99%; scan đọc được ≥97% |
| Transaction row precision/recall/F1 | Alignment bằng vị trí/thứ tự và giá trị, tính cả missing/extra rows | PDF row recall ≥99%; scan ≥97% |
| Description accuracy | Exact normalized và text similarity riêng | Không dùng fuzzy metric che sai số/ngày |
| Whole statement exact match | Tất cả dòng và core fields đúng, trước HITL | Đo baseline rồi chốt; không suy từ field accuracy |
| Confident-wrong | Sai trong các prediction tự qua / tổng prediction tự qua | Mục tiêu điểm ≤0,5%, kèm n và CI; không mặc định đã chứng minh |
| Coverage | Prediction tự qua / prediction đủ điều kiện | Báo cáo cùng risk; không đạt risk bằng cách từ chối gần hết |
| Ledger consistency | Tỷ lệ nguồn hợp lệ qua; nguồn cài lỗi bị phát hiện | Tách clean/corrupt source và lý do |
| Evidence coverage/IoU | Core fields có vùng nguồn hợp lệ; tọa độ so nhãn | 100% field tự qua có evidence |
| Latency | P50/P95 theo đường, độ dài, concurrency; cold/warm riêng | PDF 1–5 trang: P95 ≤5s; scan ≤30s là mục tiêu ban đầu |
| Usability | Hoàn thành upload→duyệt→export; thời gian, lỗi, tác vụ | ≥5 người thử; mục tiêu ≥30% giảm median thời gian duyệt với evidence |
| Cost | API usage, OCR, compute; tách actual/unpriced/estimated | Chốt trần sau khi có ngân sách và baseline |

Mục tiêu scan áp dụng trên subset có độ đọc được đã định nghĩa trước, báo cáo cả toàn bộ test và reject rate để tránh lựa chọn ca đẹp. Confidence là xác suất đúng được hiệu chuẩn từ feature có thể quan sát; không dùng điểm LLM tự báo. Cỡ mẫu nhỏ chưa đủ chứng minh risk 0,5%: nếu không thấy lỗi ở n prediction độc lập, cận trên 95% xấp xỉ 3/n; tài liệu có các dòng tương quan nên phải báo cáo thêm theo tài liệu/cluster. Khi bằng chứng chưa đủ, giữ human approval thay vì tuyên bố auto-accept an toàn.

## 6. Các mốc kiến trúc đích

Bảng này biểu diễn nhóm năng lực, không là lịch thực hiện tuần tự. Lịch có hiệu lực ở delivery plan đưa scan và PDF chạy song song từ tuần đầu.

| Mốc | Nội dung chứng minh | Tasks | Điều kiện qua |
|---|---|---|---|
| M0 — Contract | Yêu cầu, schema, kiến trúc, ca kiểm tra, môi trường dựng được | T01–T05 | Agreement về scope/DoD, skeleton CI xanh |
| M1 — Walking skeleton | Tài liệu tổng hợp → parser → validation → JSON | T06–T16 | Chạy CLI bằng một lệnh, phát hiện ca số dư sai; chưa cần LLM |
| M2 — PDF product | Đăng nhập → upload → review có evidence → approve → export | T17–T25 | Hai vai trò thực tế, persist/restart đúng, 1 demo lỗi và 1 demo sửa |
| M3 — Scan + adaptive layout | OCR, router, LLM token mapping, template config | T26–T31 | Scan bắt buộc chạy E2E; layout mới thêm bằng config được kiểm thử |
| M4 — Measured product | Calibration, benchmark, cost, hiệu năng, usability | T32–T38 | Report có n, coverage/risk, latency/cost, baseline và giới hạn |
| M5 — Release | Security checks, fault recovery, deployment, tài liệu, rehearsal | T39–T43 | Clone sạch, CI, demo deploy, artifact tái lập |
| M6 — Nâng cao tùy nguồn lực | Gợi ý dòng lỗi nâng cao, corrections/template regression | T44–T46 | Không làm chậm bản release cốt lõi |

Đường găng: schema → generator + token contract → row reconstruction → validators → persistence/job API → evidence UI + approval/export → scan integration → calibration/eval → release.

Có thể thực hiện song song theo vai trò sau T03: (A) data/eval, (B) backend/extraction, (C) frontend/product. Frontend dùng mock API từ contract, không đợi model xong. Tests về quyền truy cập bắt đầu từ M2, không dồn bảo mật về cuối.

Effort dài hạn xem roadmap, tính theo ngày công 6 giờ tập trung. Không quy đổi máy móc thành lịch. Công thức sơ bộ: tuần ≈ tổng ngày công × 6 / tổng giờ tập trung mỗi tuần của cả nhóm, cộng buffer. Giới hạn bởi đường găng và kỹ năng, không chỉ tổng số thành viên. Lịch và owner cho bản nộp đã chốt trong delivery plan: 112 giờ task + 23 giờ dự phòng, với PDF/scan song song.

### Nếu thiếu thời gian

Giữ đủ các yêu cầu cơ bản: scan/PDF, 50–150 golden, hai vai trò, evidence, validation, report, clone sạch. Giảm số layout, giao diện quản trị, số provider, SSE, chart nâng cao; giữ 50 tài liệu golden phân tầng nếu không đủ 150 và nêu hạn chế. Hoãn T44–T46. Không bỏ scan rồi gọi sản phẩm đủ yêu cầu IDP-13.

### Nếu thiếu ngân sách hoặc GPU

Dùng CPU PDF parser và OCR lightweight; API chỉ ca khó với quota. Nếu không dùng API, ưu tiên template/rules và 3 layout sâu; đo local OCR trước khi mua GPU. Lưu fixture chỉ cho test/demo offline có nhãn rõ; benchmark thực tế không tính response replay như model live.

## 7. Chính sách dữ liệu và vận hành bản nộp

- Demo chỉ nhận tài liệu tổng hợp đã đăng ký hoặc chế độ local upload có cảnh báo rõ; public demo ưu tiên chọn sample, có rate limit và TTL.
- Private file store, authorization tại mọi endpoint file/ảnh/export; không dùng đường dẫn đoán được hoặc static public folder.
- Log mặc định chỉ request/job ID, status, latency, cost; không có văn bản giao dịch, số tài khoản, nội dung prompt.
- Hai vai trò được kiểm tra server-side; người tạo/sửa không tự phê duyệt tài liệu của mình nếu policy maker-checker bật.
- Snapshot extraction gốc và revision được lưu riêng; optimistic locking chống mất sửa; edit sau approve hủy approval, revalidate rồi duyệt lại.
- Parser chạy worker có resource limit; PDFium xử lý bằng process hoặc cơ chế an toàn thư viện, không tùy tiện gọi đồng thời từ nhiều thread.
- Xóa tài liệu bao gồm original, renders, OCR/cache, exports theo retention; log audit tối thiểu còn lại phải không chứa payload tài liệu.
- Chi phí quota/retry có hard limit; out-of-budget hoặc provider timeout trả trạng thái có thể hành động.
- Pilot dữ liệu thật là cổng bàn giao riêng: cần quyền xử lý, retention, provider terms, vùng dữ liệu, phân quyền và kiểm thử trên môi trường doanh nghiệp. Bản nộp không được mô tả là đã xác nhận production accuracy trên dữ liệu thật.

## 8. Definition of Done toàn dự án

- [ ] Mọi yêu cầu cơ bản IDP-13 có task, test và artifact đối chiếu.
- [ ] Chạy được từ clone sạch qua Docker Compose và một lệnh CLI E2E.
- [ ] PDF sạch, nhiều trang, scan và mixed đều đi hết luồng.
- [ ] Source chứng minh từng giá trị số; missing/ambiguous phải hiển thị rõ.
- [ ] Mất dòng, sai số, provider fail và file lỗi không trả rỗng hoặc thành công giả.
- [ ] Hai vai trò, audit, approval/export và kiểm tra quyền được thực thi phía server.
- [ ] Golden frozen; baseline và final report có hash/version/seed, n, sai số, chi phí và cấu hình phần cứng.
- [ ] UX test, load test, negative test và recovery test đạt gate đã chốt.
- [ ] README, hướng dẫn nghiệp vụ, demo script, video dự phòng và báo cáo hạn chế hoàn chỉnh.
- [ ] Release có notices và nguồn dataset/font/model; không có secret hoặc dữ liệu thật.

## 9. Nguồn kỹ thuật để ra quyết định

- pdfplumber: https://github.com/jsvine/pdfplumber — token, bảng và MIT license.
- pypdfium2: https://github.com/pypdfium2-team/pypdfium2 — rendering và license đi kèm binary.
- PDFium concurrency: https://pypdfium2.readthedocs.io/en/stable/python_api.html — kiểm tra version pin trước triển khai song song.
- PyMuPDF: https://pymupdf.io/licensing — AGPL/commercial.
- PaddleOCR: https://github.com/PaddlePaddle/PaddleOCR — OCR adapter ứng viên; kiểm tra weights riêng.
- PDF.js: https://mozilla.github.io/pdf.js/examples/ — viewport, scale và transform.
- OWASP file upload: https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html — validate type, quyền và giới hạn.

Backlog thực thi chi tiết: [IDP13_TASK_BACKLOG.md](IDP13_TASK_BACKLOG.md).
