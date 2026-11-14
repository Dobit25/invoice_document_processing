# StatementReader — Kế hoạch bàn giao IDP-13 ngày 05/12/2026

Đây là **kế hoạch thực thi ưu tiên cao nhất**. Ngày lập 14/11/2026, giờ Việt Nam. Tất cả task đang TODO; code chưa được triển khai. Sản phẩm độc lập, dữ liệu hoàn toàn tổng hợp.

## 1. Nguồn lực và mức cam kết thực tế

- Nhóm: một BA, hai developer có khả năng code và hiểu kiến trúc.
- Mỗi người 15 giờ/tuần × ba tuần = 45 giờ/người, khoảng 135 giờ nhóm; developer chỉ có tổng 90 giờ. Chưa biết lịch học/công việc, nên 135 giờ là trần kế hoạch, không phải lịch rảnh đã xác nhận.
- Kế hoạch có 112 giờ công việc (D1 38h, D2 38h, BA 36h) + 23 giờ dự phòng (7h, 7h, 9h). Effort bao gồm đọc tài liệu, review và test trong từng task; buffer cho integration và lỗi bất ngờ.
- Hạn 05/12/2026; đóng tính năng ngày 27/11, release candidate ngày 02/12, rehearsal/đóng gói ngày 04/12. Giữ ngày 05/12 cho nộp; chưa biết giờ đóng cổng nên không đặt lịch triển khai vào ngày đó.
- Máy hiện có: RAM 16GB, RTX 4050, i5-13450HX theo thông tin cung cấp. Không giả định VRAM hay khả năng chạy VLM lớn; không đưa train/fine-tune vào phạm vi.
- API OpenAI: 12 USD, bổ sung tối đa 5 USD nếu cần; quota daily 2,5M/250k do người dùng cung cấp, **chưa kiểm tra tài khoản, eligibility và model cụ thể**.
- Rubric bổ sung chưa có. Khi rubric xuất hiện, BA đối chiếu lại requirement matrix trước khi bổ sung tính năng.

Một hệ thống production đầy đủ trong 90 giờ coding là không thực tế. Đích bàn giao là demo E2E có chất lượng, có kiểm thử và benchmark tái lập trên dữ liệu tổng hợp, có giới hạn input công bố rõ.

## 2. Hướng chọn và phương án thay thế

**Chọn hybrid nhẹ, làm PDF và scan song song từ đầu.**

PDF → pdfplumber tokens; scan → OCR local giữ token/bbox; sau đó cùng row reconstruction → chuẩn hóa Decimal/date → validator → review. OpenAI dùng để chọn token/cột/ghép dòng khó và đọc lại crop khi cần; code sao chép từ transcription nguồn. Không dùng LLM tự giải phương trình rồi điền số.

| Hướng | Điều kiện áp dụng | Mốc quyết định | Đánh đổi |
|---|---|---|---|
| A. Parser + OCR + LLM mapping | Hướng chính | Mặc định | Cần làm row/evidence tốt, chi phí API nhỏ |
| B. VLM transcription crop + token alignment | OCR local không đọc được số/tiếng Việt đủ tốt | Sau spike 18/11 | Crop được VLM đọc như bản transcription riêng có provenance; không trộn ngầm vào OCR cũ; bbox và số chưa xác minh phải review |
| C. Parser + OCR/rules, tắt cloud | API hết credit hoặc mạng lỗi | Bật cấu hình bất cứ lúc nào | Giữ supported templates; ca khó review; không hứa xử lý unknown layout tốt |

OCR spike chỉ dành tối đa 2 giờ trong S07: thử Tesseract `vie+eng` hoặc PaddleOCR đã có môi trường phù hợp, rồi giữ **một** backend. Chưa cài OCR trong phiên lập kế hoạch. VLM local nặng, model training và nhiều provider không cần cho hạn này.

### Stack bản nộp

- Python 3.12/FastAPI/Pydantic/SQLAlchemy, SQLite WAL, Decimal dạng chuỗi ở JSON, private file directory.
- Một worker process đọc jobs từ SQLite; transactional claim/heartbeat, idempotent results, startup recovery. Một worker, tối đa một tài liệu xử lý nặng mỗi lúc; concurrency API cloud nhỏ có giới hạn. Chưa dùng Celery/Redis/PostgreSQL.
- React/TypeScript/Vite + PDF.js + table component có windowing nếu cần; chọn một component library, không tự làm design system lớn.
- pdfplumber + pypdfium2; OCR adapter và OpenAI adapter. Pin model ID sau khi xác nhận account và chạy 10 trang dev; không khóa vào model cũ chỉ vì ví dụ trên mạng.
- Docker Compose cho web/API/worker với shared volumes. Database và file access theo single-host design, không mô tả là multi-node architecture.
- Poll job status, không cần SSE/WebSocket. CLI và worker dùng chung pipeline.
- PDF.js transforms và renderer chạy process-safe; không fan-out PDFium bằng thread tùy tiện.

### Phạm vi sản phẩm bắt buộc trước nộp

1. PDF text layer, PNG/JPEG và PDF scan/mixed; file tối đa đề xuất 10MB, 10 trang, VND, 3 họ bố cục; scan đánh máy. Giới hạn sau spike có thể điều chỉnh có ghi lý do.
2. Bảng ngày/mô tả/debit/credit/balance; multiline, header lặp, carry-forward, nhiều trang, biến thể số/ngày theo template.
3. Mỗi dòng có evidence; giá trị số tự đọc phải truy về transcription nguồn. Sửa thủ công có actor/reason riêng.
4. Running balance + opening/closing; phát hiện unresolved rows/page failure; không coi balance-pass là bằng chứng mọi trường đúng.
5. Login hai vai trò, upload/progress/history, reviewer hai cột, edit/revalidate/approve, CSV/XLSX/JSON có revision.
6. Golden 60 sao kê, report field/row accuracy, pass rate, confident-wrong và n, latency/cost; uncertainty ghi rõ.
7. Một lệnh dựng demo và một lệnh CLI từ input ra output; có demo sample khi không Internet và phân biệt replay/live nếu dùng fixture.

P1 nếu còn thời gian: onboarding layout thứ 4 bằng YAML (S20 có timebox), keyboard polish, chart nhỏ. Nếu cut S20, chuyển 2 giờ sang sửa lỗi cốt lõi, không lấy từ buffer để mở scope.

Sau deadline: PostgreSQL/Redis/Celery, multi-tenant/SSO, correction-learning, template studio, benchmark 150+ và pilot doanh nghiệp. Xem roadmap 46 T-task để mở rộng có hệ thống.

## 3. API và bảo mật: quyết định cho bản nộp

**API cloud có thể dùng cho bản nộp với dữ liệu hoàn toàn tổng hợp. Gửi sao kê thật ra API là truyền dữ liệu tới bên thứ ba, dù đường truyền được mã hóa. Không thể cam kết “không đưa dữ liệu ra ngoài” khi gửi payload tới cloud.** Việc dùng API cho một nghiệp vụ khác không xác lập quyền xử lý sao kê ngân hàng.

OpenAI mặc định không dùng API input/output để huấn luyện, trừ khi khách hàng opt-in chia sẻ. Tuy nhiên quota 2,5M/250k tương ứng mức incentive có thể nhận khi bật chia sẻ input/output; đây là dấu hiệu cần kiểm tra, **không phải kết luận đã thấy account của nhóm**. Tài liệu OpenAI yêu cầu không đưa thông tin nhạy cảm/bí mật vào traffic chia sẻ.

Hành động S01/S09: kiểm tra Data Controls và Usage ở **đúng organization/project**, model nào hưởng quota, phần quota nào đã dùng; ghi nhận thiết lập không có secret. Không đổi account settings trong giai đoạn lập kế hoạch.

- Synthetic sandbox riêng có thể dùng ưu đãi sharing nếu nhóm đã bật/đủ điều kiện; payload chỉ synthetic, không API key/password, không tài liệu nội bộ.
- Pilot thật dùng project/organization không opt-in chia sẻ, được doanh nghiệp cho phép, provider terms/retention phù hợp; nếu cần không rời hạ tầng thì chọn local-only.
- `store=false` giảm application-state storage theo endpoint; **không bật Zero Data Retention**, không vô hiệu hóa việc opt-in sharing. Abuse logs mặc định có thể lưu tới 30 ngày; ZDR có điều kiện và giới hạn endpoint/feature.
- Không file-search/vector store/tracing service bên ngoài cho bản nộp. Crop trang/header nhạy cảm có thể giảm payload nhưng che tên/tài khoản không làm lịch sử giao dịch tự động vô danh.
- Backend giữ API key, client không gọi OpenAI trực tiếp; logs metadata-only, private files, authorization, TTL, không đưa raw prompt vào repo.
- Public demo ưu tiên sample-only; upload tự do phục vụ local demo để tránh người dùng vô tình đưa sao kê thật vào sandbox.

Nguồn: [OpenAI Data Controls](https://developers.openai.com/api/docs/guides/your-data), [sharing và complimentary tokens](https://help.openai.com/en/articles/10306912-sharing-feedback-evaluation-and-fine-tuning-data-and-api-inputs-and-outputs-with-openai), [API pricing](https://developers.openai.com/api/docs/pricing).

### Budget API

| Khoản dự trù | Trần USD |
|---|---:|
| Spike 10 trang, chọn model | 1 |
| Dev/debug có cache + fixture | 3 |
| Calibration + final benchmark | 4 |
| Demo/rehearsal và contingency API | 4 |
| Tổng cơ sở | 12 |
| Bổ sung chỉ khi đã xem usage | tối đa 5 |

Đây là phong bì chi tiêu, không phải dự đoán chính xác số trang xử lý được. Công thức: input_tokens × input_rate + cached_tokens × cached_rate + output/reasoning_tokens × output_rate, theo đơn vị bảng giá; thêm image/OCR/tools nếu có. Sau 10 trang live, S09 ghi actual USD/page rồi tính số trang tối đa theo số dư còn lại. Ưu đãi quota không thay thế rate limit RPM/TPM và có thể không bao phủ mọi feature/model.

Ứng dụng phải có cost cap kiểm tra **trước** call với estimate max output, giới hạn retry tối đa 1–2; ghi usage thật sau call để tránh vượt do retry/concurrency. Đến 8 USD review ngân sách, tới 10 USD giảm call lặp, chạm 12 USD dừng chi tiêu kế hoạch; chỉ dùng phần 5 USD bổ sung sau quyết định của nhóm. Project budget dashboard có thể chỉ là cảnh báo; không coi nó là hard cap. Không tự nạp tiền trong workflow.

## 4. Data và mục tiêu đo

- 30 dev + 30 calibration + 60 golden, 3 layout; mỗi split có PDF/scan/mixed, không để bản scan của cùng sao kê xuất hiện ở split khác.
- Golden 60 = 3 layout × (8 PDF + 8 scan + 4 mixed); các tài liệu có 1–5 trang chủ yếu, một số 6–10 trang để thử giới hạn. Ít nhất một mẫu nguồn số dư sai và một zero-transaction ở mỗi layout; chỉ định nhãn trước chạy.
- BA kiểm tra nội dung và 15 tài liệu/GT bbox bằng mắt; developer làm generator, BA chỉnh YAML và chạy lệnh có hướng dẫn, không giao BA viết OCR hay evaluation engine.
- Golden manifest đóng trước tối ưu; evaluator chỉ chạy golden lúc freeze. Nếu dùng golden để debug thì ghi test contamination và tạo bộ mới trước final claim.
- Benchmark layout thứ 4 chưa thấy là P1; nếu chưa làm phải ghi kết quả chỉ cho 3 họ layout và biến thể, không tuyên bố generalization mọi ngân hàng.
- Khóa số liệu trước HITL; sau HITL báo riêng. Tính row omissions/extra dù balance vẫn khớp. Dùng Decimal; không tự sort giao dịch cùng ngày hoặc loại duplicate.
- Mục tiêu kỹ thuật đề xuất: field số/ngày PDF ≥99%, scan readable ≥97%, đủ evidence cho mọi số được tự qua; P95 PDF ≤5s và scan ≤30s cho 1–5 trang chỉ là target ban đầu cần đo. Không đạt target thì giữ toàn bộ kết quả và phân tích, không giấu nhóm thất bại.
- Confidence: bắt đầu score features có ý nghĩa, empirical calibration bins trên calibration set; thiếu n thì hiển thị “chưa đủ dữ liệu hiệu chuẩn”. Threshold chọn trước golden, confident-wrong nêu cả denominator và confidence interval; chưa đủ bằng chứng về risk 0,5% thì không tuyên bố đạt. Toàn bộ export chính thức vẫn có accountant approval.

## 5. Backlog có thể giao việc ngay

Ký hiệu D1: developer backend/domain/PDF; D2: developer frontend/scan/API integration; BA: phân tích, dữ liệu, QA, UX, báo cáo. Owner phụ hỗ trợ review nằm trong effort task; không double-count giờ. File paths là đề xuất triển khai. Mỗi task có mục đích, DoD và phạm vi; T IDs tham chiếu roadmap để đào sâu kỹ thuật, không cộng effort hai lần.

### S01 — Scope, acceptance và API data settings [BA · 5h · tuần 1]

- **Mục đích:** chốt input, nghiệp vụ, quyền, data policy và rubric mapping.
- **Phụ thuộc:** không. **Files:** `docs/product/{scope,requirements-matrix,acceptance}.md`, `docs/security/api-policy.md`.
- **DoD:** từng yêu cầu IDP-13 → task → bằng chứng; xác nhận 3 layout/VND/giới hạn; thuật ngữ debit/credit; kiểm tra đúng project sharing/quota, không chép secret; checklist kiểm thử nguồn hợp lệ/sai và lỗi kỹ thuật. Map T01/T05/T39.

### S02 — Contract, skeleton và CLI chung [D1 · 3h · tuần 1]

- **Mục đích:** hai developer tích hợp bằng cùng token/row schema.
- **Phụ thuộc:** S01 bản đầu. **Files:** `backend/{pyproject.toml,uv.lock}`, `backend/app/{main,cli}.py`, `backend/app/domain/{statement,evidence,validation,jobs}.py`, `contracts/examples/statement.json`, `.env.example`, `.gitignore`.
- **DoD:** schema validate example, money string/Decimal, stable IDs/bbox normalized, revisions/errors; health API và CLI trả mock hợp lệ; D2 dùng fixture; env không commit. Map T03/T04/T16.

### S03 — UI skeleton và mock API [D2 · 2h · tuần 1]

- **Mục đích:** dựng luồng và visual style khi engine đang làm.
- **Phụ thuộc:** S02 fixture. **Files:** `frontend/{package.json,package-lock.json,vite.config.ts}`, `frontend/src/{App.tsx,api/client.ts,mocks/statement.json,styles.css}`.
- **DoD:** login/upload/review shell render mock, UI tiếng Việt, consistent spacing/colors/type; loading/error placeholders; install từ lock. Map T04/T05/T21.

### S04 — Synthetic generator tối thiểu [D1 · 5h · tuần 1]

- **Mục đích:** có nguồn tài liệu và nhãn độc lập với extractor.
- **Phụ thuộc:** S02. **Files:** `tools/synthetic/{ledger,render,ground_truth,cli}.py`, `tools/synthetic/layouts/{a,b,c}.yaml`, `tests/data/test_generator.py`, `assets/fonts/NOTICE.md`.
- **DoD:** seed→ledger→PDF/scan+GT value/bbox; 3 layouts, multiline/page/header/carry-forward/locale, clean và source-error scenarios; font tiếng Việt; BA chạy được CLI; sample PDF/scan bàn giao sớm, không chờ generator hoàn hảo. Map T06–T08.

### S05 — Corpus, split, GT QA [BA · 6h · tuần 1]

- **Mục đích:** dữ liệu đúng, đủ ca khó, không leakage.
- **Phụ thuộc:** S04 bản chạy được. **Files:** `data/{README.md,splits.json,golden_manifest.json,qa.csv}`, `tools/synthetic/scenarios.yaml`.
- **DoD:** 30/30/60 đúng phân tầng; biến thể cùng statement không qua split; kiểm tra ≥15 samples, cả bbox/số/ngày/row count; danh tính hư cấu; freeze checksum golden và lưu nhãn ngoài worker. Map T09.

### S06 — PDF tokens/render [D1 · 4h · tuần 1]

- **Mục đích:** baseline PDF nhanh và giữ nguồn.
- **Phụ thuộc:** S02, S04 sample. **Files:** `backend/app/documents/{inspect,render,geometry}.py`, `backend/app/extraction/pdf_tokens.py`, `tests/extraction/test_pdf.py`.
- **DoD:** text+bbox cho 3 layout, page dims/rotation/cropbox rõ; corrupted/encrypted trả lỗi; render process-safe; round-trip bbox trên zoom/rotation fixture. Map T11/T12.

### S07 — Scan OCR spike và adapter [D2 · 4h · tuần 1]

- **Mục đích:** scan có token contract ngay tuần đầu.
- **Phụ thuộc:** S02, S04 scan sample. **Files:** `backend/app/ocr/{adapter,preprocess}.py`, `tests/ocr/test_scan.py`, `docs/qa/ocr-choice.md`.
- **DoD:** chọn một OCR trong 2h đầu; numeric/text tokens+bbox, rotation transforms và unreadable status; test ảnh clean/blur/rotation; nếu không đạt chuyển crop VLM có evidence theo nhánh B, không bỏ scan. Map T02/T26.

### S08 — Row reconstruction, normalization, validator [D1 · 6h · tuần 1–2]

- **Mục đích:** PDF/OCR token cùng ra giao dịch có kiểm tra tài chính.
- **Phụ thuộc:** S06 và contract S07; có thể viết bằng mock OCR trước. **Files:** `backend/app/extraction/{rows,templates}.py`, `backend/app/validation/{money,dates,ledger,coverage}.py`, `configs/templates/{a,b,c}.yaml`, `tests/validation/test_ledger.py`, `tests/extraction/test_rows.py`.
- **DoD:** 3 layout, multiline/header/carry-forward, source order, missing-vs-zero; running/period balance và unresolved rows; test cặp bù nhau, duplicate thật, missing page và source sai; CLI PDF+scan chạy engine chung. Map T13–T16/T29 cốt lõi.

### S09 — OpenAI mapping, fallback và cost cap [D2 · 4h · tuần 1]

- **Mục đích:** xử lý layout ambiguity trong ngân sách và policy.
- **Phụ thuộc:** S02, S01 policy, S07 tokens. **Files:** `backend/app/llm/{provider,mapping}.py`, `backend/app/prompts/mapping.md`, `backend/app/telemetry/cost.py`, `configs/{models,pricing,budget}.yaml`, `tests/llm/test_mapping.py`.
- **DoD:** chọn model đang có quyền sau 10 trang dev; structured output token IDs, raw-copy bằng code; unknown IDs/số bịa bị chặn; crop transcription có provenance riêng; retry/timeouts/caps + store=false; actual cost và giá thiếu unpriced; fixture synthetic cho offline unit test. Map T28/T35.

### S10 — Private storage, persistent jobs và APIs [D1 · 4h · tuần 2]

- **Mục đích:** UI gọi pipeline thật, reload/restart không mất run.
- **Phụ thuộc:** S08, tích hợp S09 khi sẵn. **Files:** `backend/app/{db.py,worker.py}`, `backend/app/api/{documents,jobs}.py`, `backend/app/storage.py`, `tests/integration/test_jobs.py`.
- **DoD:** SQLite migrations/schema init versioned; upload/job/poll/pages/results; worker claim idempotent, heartbeat/stale recovery; giới hạn file/page/pixel; partial fail không success; metadata có pipeline/template version. Map T17/T19/T20.

### S11 — Hai vai trò, session và quyền object [D2 · 3h · tuần 1]

- **Mục đích:** quyền được thực thi trên backend từ đầu.
- **Phụ thuộc:** S02; S10 tích hợp tuần 2. **Files:** `backend/app/auth.py`, `backend/app/api/auth.py`, `backend/app/seed_demo.py`, `frontend/src/auth/Login.tsx`, `tests/security/test_roles.py`.
- **DoD:** operator edit/submit, accountant approve/export; password hash/session expiry; cookie/CSRF policy, file/job/review cũng yêu cầu auth; self-approval policy; không chỉ ẩn nút UI. Map T18.

### S12 — Evidence reviewer và progress [D2 · 7h · tuần 1–2]

- **Mục đích:** người dùng nhìn được nguồn và lỗi ngay tại dòng giao dịch.
- **Phụ thuộc:** S03/S06, dùng mock khi S10 chưa xong. **Files:** `frontend/src/features/{Upload,JobStatus,ReviewPage,PdfViewer,EvidenceOverlay,TransactionTable,IssuePanel}.tsx`, `frontend/src/api/client.ts`, `frontend/src/coordinates.ts`.
- **DoD:** upload→poll→review; click đúng page/bbox khi zoom/rotate; multiline regions; highlight lệch số dư; missing evidence rõ; loading/empty/partial/error; refresh mở lại job. Map T21/T22/T30.

### S13 — Edit/revalidate/approve/export endpoints [D1 · 4h · tuần 2]

- **Mục đích:** dữ liệu được kiểm tra và phê duyệt đúng phiên bản.
- **Phụ thuộc:** S08/S10/S11. **Files:** `backend/app/api/{reviews,exports}.py`, `backend/app/review.py`, `backend/app/export.py`, `tests/integration/test_review_export.py`.
- **DoD:** raw prediction bất biến, manual revision+audit, conflict detection; edit revalidate và hủy approval cũ; unresolved blocking issue chặn approve; CSV/XLSX/JSON dùng approved snapshot; formula injection test. Map T23/T24.

### S14 — Review controls và export UI [D2 · 4h · tuần 2]

- **Mục đích:** hoàn tất thao tác nghiệp vụ từ trình duyệt.
- **Phụ thuộc:** S12/S13. **Files:** `frontend/src/features/{FieldEditor,ApprovalBar,ExportDialog,History}.tsx`, `frontend/src/reviewState.ts`.
- **DoD:** accept/edit/reject/submit/approve theo role, revalidation hiển thị, audit timeline đơn giản, revision conflict có hướng dẫn reload; export đúng phiên bản; keyboard và focus ở tác vụ chính. Map T23/T24/T37 một phần.

### S15 — BA test luồng và failure cases [BA · 5h · tuần 2]

- **Mục đích:** phát hiện vấn đề nghiệp vụ trước freeze.
- **Phụ thuộc:** S10–S14 incremental. **Files:** `docs/qa/{scenarios,bugs,gate-week2}.md`.
- **DoD:** cả hai role hoàn thành PDF/scan/mixed→edit→approve→export; lỗi file/timeout/nguồn sai/mất dòng được ghi; bug có input synthetic, expected/actual và severity; không khai thác golden để tune. Map T25/T31.

### S16 — Evaluation protocol và oracle QA [BA · 5h · tuần 1–2]

- **Mục đích:** kết quả có denominator và tiêu chí đúng đã chốt trước.
- **Phụ thuộc:** S01, S04. **Files:** `evaluation/protocol.md`, `evaluation/expected_cases.json`, `docs/qa/metric-review.md`.
- **DoD:** định nghĩa exact field/row/statement, missing/extra, source-error detection, risk/coverage/cost/latency; BA tạo ≥10 expected outcomes kiểm evaluator, không code metric; pre/post review tách; phê duyệt schema báo cáo trước benchmark. Map T10/T33.

### S17 — Evaluator và empirical calibration [D1 · 4h · tuần 2]

- **Mục đích:** có báo cáo tái lập và confidence có cơ sở.
- **Phụ thuộc:** S08/S09/S16; calibration corpus S05. **Files:** `evaluation/{evaluate,calibrate,report}.py`, `backend/app/confidence.py`, `configs/confidence.yaml`, `tests/evaluation/test_metrics.py`.
- **DoD:** oracle tests pass; actual counts/missing/extra; calibration bins feature-based và n, chọn threshold trước golden; insufficient data không báo confidence giả; CLI report field/row/risk/pass rate và export JSON/Markdown. Map T10/T32/T33 phiên bản gọn.

### S18 — CI và đóng gói Docker [D2 · 3h · tuần 2]

- **Mục đích:** chốt khả năng chạy trên máy khác trước tuần cuối.
- **Phụ thuộc:** S10–S14. **Files:** `backend/Dockerfile`, `frontend/Dockerfile`, `compose.yaml`, `.github/workflows/ci.yml`, `scripts/{start.ps1,start.sh}`.
- **DoD:** lock install/lint/critical tests; web/API/worker shared private volume; seed idempotent, không secrets trong image; CPU OCR package/weights/license có hướng dẫn; startup smoke PDF+scan. Map T04/T41.

### S19 — E2E integration và lỗi trọng yếu [D1 · 4h · tuần 3]

- **Mục đích:** freeze pipeline có kiểm thử tích hợp, sửa lỗi accuracy đã quan sát.
- **Phụ thuộc:** S15/S17/S18. **Files:** `tests/integration/test_e2e.py`, `backend/app/pipeline.py`, các module lỗi cụ thể kèm test regression.
- **DoD:** PDF/scan/mixed đi hết luồng, export row count/amount đúng fixture; lỗi P0/P1 nghiệp vụ được xử lý trước final benchmark; freeze versions/threshold; không chỉnh dựa golden sau final run. Map T25/T31/T40.

### S20 — Thêm layout bằng config, timebox [D1 · 2h · tuần 3 · P1]

- **Mục đích:** chứng minh onboarding không cần sửa code.
- **Phụ thuộc:** S08/S19 ổn định. **Files:** `configs/templates/d.yaml`, `tests/templates/test_new_layout.py`, `docs/qa/new-layout.md`.
- **DoD:** dùng dev riêng cho layout d, chỉ thay YAML; test held-out riêng và regression a/b/c; nếu cần sửa engine vượt timebox thì hoãn, ghi phạm vi hỗ trợ ba layout. Map T29 nâng cao; không điều chỉnh golden ban đầu.

### S21 — Final benchmark live và cost report [D1 · 2h · tuần 3]

- **Mục đích:** xuất số liệu cuối và giới hạn thực tế.
- **Phụ thuộc:** S17/S19, dùng bản config đã freeze. **Files:** `reports/{release-summary.md,metrics.json,usage.json}`, `evaluation/release-config.yaml`.
- **DoD:** 60 golden chạy độc lập với labels, ghi hash/n/hardware/model/cost; pre-HITL metrics và failures đầy đủ; số lượng API calls bị giới hạn theo budget, rejected/timeout vẫn tính; nếu budget không đủ ghi subset live/replay rõ và không gộp giả. Map T33/T35.

### S22 — Failure/security checks và fix [D2 · 4h · tuần 2–3]

- **Mục đích:** bảo vệ dữ liệu và hoạt động ổn định trong demo.
- **Phụ thuộc:** S11/S13/S18. **Files:** `tests/security/test_access.py`, `tests/resilience/test_retry.py`, `backend/app/{retention,logging_policy}.py`, `frontend/e2e/review.spec.ts`.
- **DoD:** forbidden document/export access, duplicate job retry, worker restart, timeout, oversized image, formula injection, log payload/secret scan; TTL xóa files/renders/export theo policy; test public demo sample-only; không gắn nhãn production secure. Map T39/T40.

### S23 — Performance/UX fixes có đo [D2 · 3h · tuần 3]

- **Mục đích:** xử lý bottleneck thực tế và lỗi UX nghiêm trọng.
- **Phụ thuộc:** S12/S14/S25 feedback. **Files:** `evaluation/performance.py`, `frontend/src/features/PdfViewer.tsx`, `frontend/src/features/TransactionTable.tsx`, `reports/performance.md`.
- **DoD:** P50/P95 theo route, cold/warm, 1 và 3 jobs, queue wait và peak RAM; lazy pages/poll cleanup, không crash RAM16GB; sửa 2–3 lỗi usability cao nhất; không mở rộng model. Map T36/T37.

### S24 — Release smoke và artifact kỹ thuật [D2 · 4h · tuần 3]

- **Mục đích:** bản nộp dựng được và demo được kể cả mất mạng.
- **Phụ thuộc:** S18/S19/S22/S23. **Files:** `README.md`, `docs/OPERATIONS.md`, `scripts/{smoke.ps1,smoke.sh}`, `docs/submission/release-record.md`.
- **DoD:** clean clone/start/CLI PDF+scan; 2 demo accounts, offline OCR/rules path, live cloud path nếu có mạng; sample outputs/replay gắn nhãn, checksums/notices; demo tại máy nhóm là core, public URL chỉ triển khai nếu có host sẵn; không giả định budget API trả hosting. Map T41/T43.

### S25 — Usability test [BA · 6h · tuần 2]

- **Mục đích:** đánh giá sản phẩm có dễ dùng và kiểm tra nhanh.
- **Phụ thuộc:** S12/S14 đủ chạy. **Files:** `docs/ux/{protocol,results,fix-priorities}.md`.
- **DoD:** mục tiêu 5 người thử, ít nhất 3 nếu tuyển không đủ và ghi hạn chế; tác vụ PDF/scan/lệch số dư, đo thời gian và lỗi; có đối trọng thứ tự khi so evidence; feedback có mức độ và đề xuất cụ thể cho S23. Map T37.

### S26 — Report, demo, BA sign-off và nộp [BA · 9h · tuần 2–3]

- **Mục đích:** hội đồng hiểu vấn đề, kết quả và kiểm chứng được bằng chứng.
- **Phụ thuộc:** S15/S16/S21/S24/S25 theo tiến độ. **Files:** `docs/submission/{report,demo-script,requirements-evidence,limitations,submission-checklist}.md`, `docs/USER_GUIDE.md`.
- **DoD:** nội dung chuẩn bị sớm, chỉ điền actual metrics sau S21; giải thích synthetic-to-real gap và calibration n nhỏ; demo 5–7 phút clean+scan+error+edit+approve+export, video dự phòng; người khác rehearsal từ README; kiểm tra định dạng/giờ portal trước nộp, lưu biên nhận. Đây là task triển khai tương lai, chưa có nộp report hoặc external write trong phiên lập kế hoạch.

## 6. Lịch theo tuần và kiểm tra tải

| Tuần | D1 — tối đa 15h | D2 — tối đa 15h | BA — tối đa 15h | Gate |
|---|---|---|---|---|
| 14–20/11 | S02 3h; S04 5h; S06 4h; S08 3h | S03 2h; S07 4h; S09 4h; S11 3h; S12 2h | S01 5h; S05 6h; S16 4h | Token PDF+scan, schema chung, UI mock, dataset và policy |
| 21–27/11 | S08 3h; S10 4h; S13 4h; S17 4h | S12 5h; S14 4h; S18 3h; S22 3h | S16 1h; S15 5h; S25 6h; S26 3h | E2E cả PDF/scan, 2 role, review/export; feature freeze |
| 28/11–04/12 | S19 4h; S20 2h; S21 2h; buffer 7h | S22 1h; S23 3h; S24 4h; buffer 7h | S26 6h; buffer 9h | Final metrics, RC02/12, rehearsal04/12 |

Tuần đầu D2 có nhiều nhánh: UI dùng component library và mock; không làm visual customization sâu. Nếu S07/S09 vượt 2 giờ so estimate, giảm theme/chart/P1 trước. D1 mở generator sample và schema rất sớm để D2 không chờ tới cuối tuần. Hai dev review chung contract 20–30 phút trong S02, chi phí đã tính.

Điểm hội tụ thứ hai là S13 API → S14 UI. Để tránh chờ, endpoint request/response của review/export phải có example từ S02 và D2 có mock. BA thực hiện QA trên dev corpus và mock trước rồi xác nhận lại tích hợp thật.

## 7. Stop/go, cắt scope và kế hoạch dự phòng

| Hạn | Nếu chưa đạt | Hành động |
|---|---|---|
| 18/11 | OCR local chưa trả token+bbox đủ dùng | Chọn backend duy nhất hoặc crop-VLM transcription; bỏ hỗ trợ ảnh quá xấu, ghi unreadable; giữ scan clean |
| 20/11 | PDF/scan chưa chung contract | Dừng polish, D1/D2 tập trung source tokens→row JSON, BA tiếp tục QA/data |
| 24/11 | Bảng còn mất dòng nhiều | Giới hạn supported templates, tăng manual review; không thêm provider |
| 27/11 | Upload→review→approve→export chưa chạy | Cắt S20 và chart/history nâng cao; buffer dành tích hợp, không thêm tính năng |
| 30/11 | Không đủ n để hiệu chuẩn confidence | Hiển thị n/interval, confidence unavailable ở nhóm nhỏ, report threshold/risk thận trọng; giữ người phê duyệt |
| 02/12 | RC còn lỗi mất dòng/giá trị hoặc lộ quyền | Fix core; dừng nâng cao, ghi limitation, không che failure |
| 04/12 | Không có public hosting | Demo local có Docker, video + CLI + artifacts; báo mentor sớm nếu rubric mới bắt public deploy |

Nếu phát sinh rubric yêu cầu public URL, lấy 2–4h trong buffer D2 cho deployment trên host đã có; chi phí hosting cần chốt riêng, không tự lấy toàn bộ 12 USD API. Không lộ local dev server qua URL công khai thiếu auth.

## 8. Definition of Done bản nộp

- [ ] Hai nhánh PDF và scan/mixed chạy E2E, không im lặng bỏ trang/dòng.
- [ ] Số tiền/ngày được parse bằng code và có nguồn; user edits giữ audit.
- [ ] Review có evidence, validation issues và phê duyệt đúng role/revision.
- [ ] Một lệnh CLI input→output; clean clone khởi chạy được UI/backend/worker.
- [ ] 60 golden frozen, report có field/row accuracy+n, running-balance pass, confident-wrong/coverage, latency/cost và failures.
- [ ] Hai tài khoản, private files, no payload logs, no API key frontend, export injection và access tests pass.
- [ ] UI được người thử dùng; có sửa lỗi UX chính và hướng dẫn tiếng Việt.
- [ ] Demo script/video, README, notices, report synthetic-only và limitations đầy đủ.
- [ ] Không claim production accuracy, không claim risk thấp hơn mức cỡ mẫu có thể chứng minh, không claim cloud request không rời hạ tầng.

## 9. Tài liệu liên quan

- [Master plan: kiến trúc đích và metric](IDP13_MASTER_PLAN.md).
- [Roadmap 46 T-task: mở rộng sau deadline](IDP13_TASK_BACKLOG.md).

Task S01/S02/S03/S04/S07 có thể bắt đầu ngay sau buổi kickoff; chưa cần đợi rubric mới. Lập kế hoạch không đồng nghĩa đã triển khai code, gọi API trả phí, sửa account settings hoặc nộp lên portal.
