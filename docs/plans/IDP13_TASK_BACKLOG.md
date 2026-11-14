# IDP-13 — Backlog thực thi

Đây là **roadmap kỹ thuật toàn sản phẩm**, không là cam kết thực hiện trước 05/12/2026. Tổng effort tham chiếu 57 ngày công × 6 giờ = 342 giờ, vượt nguồn lực hiện có. **Dùng [delivery plan](IDP13_DELIVERY_PLAN.md) làm backlog thực thi**: 26 task thu gọn với 112 giờ dự kiến và 23 giờ dự phòng. P0 bên dưới chỉ mức quan trọng trong sản phẩm đích; phạm vi tối thiểu tương ứng được gom vào các S-task của bản nộp.

Đọc cùng [master plan](IDP13_MASTER_PLAN.md). Mọi task dưới đây đang ở trạng thái **TODO**. Đây là file scope dự kiến để chia việc; không yêu cầu tạo trước mọi file rỗng.

Quy ước: P0 = bắt buộc trước nộp; P1 = tăng chất lượng/thể hiện nâng cao, có thể giảm độ sâu; P2 = sau core release. Effort là ngày công 6 giờ tập trung, chưa gồm buffer 20–30%. Task >2 ngày nên tách PR theo contract/integration; không ghép cả phase thành một PR.

Mỗi task chỉ hoàn tất khi có đầu ra được review, test đúng rủi ro và bằng chứng DoD. Một module chạy được trên sample đẹp chưa đáp ứng DoD. Task thay đổi contract cần cập nhật schema/OpenAPI và consumer liên quan. Task tài liệu không cần unit test.

## M0 — Scope, kiến trúc, môi trường

### T01 — Chốt phạm vi và traceability [P0 · 0,5 ngày]

- **Mục đích:** mọi yêu cầu của đề bài có đầu ra, giới hạn và cách nghiệm thu.
- **Phụ thuộc:** không.
- **Files:** `docs/product/scope.md`, `docs/product/requirements-matrix.md`, `docs/product/acceptance.md`.
- **DoD:** mapping từng yêu cầu gốc → task ID → test/report; nêu input limits, trường bắt buộc, supported/unsupported, hai vai trò, MVP vs nâng cao; deadline/budget/owner được điền khi có thông tin.

### T02 — Chọn kiến trúc và adapter qua spike [P0 · 1,5 ngày]

- **Mục đích:** chọn parser/render/OCR/provider có bằng chứng trước khi phụ thuộc sâu.
- **Phụ thuộc:** T01.
- **Files:** `experiments/parser_spike.py`, `experiments/ocr_spike.py`, `docs/architecture/ADR-001-stack.md`, `docs/legal/dependencies.md`, `THIRD_PARTY_NOTICES.md`.
- **DoD:** chạy cùng ≥10 sample tổng hợp dev, ghi coordinate quality, numeric errors, latency/RAM và chi phí nếu có; chọn 1 parser/renderer, 1 OCR chính, 1 LLM adapter tùy chọn; pin version/model ID và license code/weights/font/binary. Spike không truy cập golden.

### T03 — Domain contracts và API specification [P0 · 1 ngày]

- **Mục đích:** backend, data và UI phát triển theo cùng hợp đồng.
- **Phụ thuộc:** T01.
- **Files:** `backend/app/domain/{statement,evidence,validation,jobs,review}.py`, `contracts/openapi.yaml`, `contracts/examples/{statement,job,review}.json`, `frontend/src/api/generated.ts`.
- **DoD:** schema cho Decimal-as-string, nullable/zero, stable IDs, multi-region evidence, versions, error codes và revision; API example được validate; frontend types sinh lại bằng lệnh có tài liệu. Quy ước bbox, ngày, dấu và ordering được ghi rõ.

### T04 — Bootstrap repository và CI [P0 · 1 ngày]

- **Mục đích:** mọi máy có môi trường nhất quán và thay đổi được kiểm tra sớm.
- **Phụ thuộc:** T02, T03.
- **Files:** `backend/pyproject.toml`, `backend/uv.lock`, `frontend/{package.json,package-lock.json,tsconfig.json,vite.config.ts}`, `.gitignore`, `.env.example`, `.github/workflows/ci.yml`, `scripts/{dev.ps1,dev.sh}`, `README.md`.
- **DoD:** Python/Node version chốt, install từ lock; lint/typecheck/schema checks/test bootstrap chạy CI; `.env`, runtime uploads và dataset generated không vô tình commit; không xóa file workbook hiện có.

### T05 — Thiết kế UX và tiêu chí tác vụ [P0 · 1 ngày]

- **Mục đích:** xác định thao tác nghiệp vụ và failure states trước khi làm UI.
- **Phụ thuộc:** T01, T03.
- **Files:** `docs/product/user-flows.md`, `docs/ux/wireframes.md`, `docs/ux/usability-protocol.md`, `frontend/src/mocks/{handlers,fixtures}.ts`.
- **DoD:** wireframe inbox/upload/progress/review/export; treasury operator và accountant có quyền rõ; trạng thái loading/partial/unsupported/no-transactions/error/approved; kịch bản thao tác đo được. Mocks khớp contract; thuật ngữ tiếng Việt thống nhất.

## M1 — Data và pipeline CLI

### T06 — Generator giao dịch và ledger chuẩn [P0 · 1 ngày]

- **Mục đích:** tạo dữ liệu độc lập, có ground truth đúng và ca lỗi chủ đích.
- **Phụ thuộc:** T03, T04.
- **Files:** `tools/synthetic/{ledger,entities,scenarios,cli}.py`, `tools/synthetic/configs/base.yaml`, `tests/data/test_ledger_generation.py`.
- **DoD:** seed cố định tái tạo giao dịch/ngày/số dư; accounts hư cấu; duplicate thật, reversal, fee, cùng ngày, zero-transaction, ascending/descending; lỗi nguồn chỉ xuất hiện trong scenario cài lỗi có nhãn.

### T07 — Render nhiều layout và lưu evidence ground truth [P0 · 1,5 ngày]

- **Mục đích:** dữ liệu kiểm tra extraction và tọa độ chứ không chỉ giá trị.
- **Phụ thuộc:** T06.
- **Files:** `tools/synthetic/{render_pdf,layouts,ground_truth}.py`, `tools/synthetic/layouts/{alpha,beta,gamma,delta,epsilon,zeta}.yaml`, `assets/fonts/NOTICE.md`, `tests/data/test_render_truth.py`.
- **DoD:** 6 họ layout có header, multiline, page-break, carry-forward, locale số; font tiếng Việt có license; GT lưu trường/dòng/page/bbox và row kind; sample visual QA xác nhận render thực tế khớp nhãn, không lấy extraction pipeline làm oracle GT.

### T08 — Scan degradation và negative corpus [P0 · 1 ngày]

- **Mục đích:** kiểm thử độ bền và tình huống không đọc được.
- **Phụ thuộc:** T07, T02.
- **Files:** `tools/synthetic/{degrade,capture_manifest,negative_cases}.py`, `tools/synthetic/configs/degradation.yaml`, `tests/fixtures/negative/manifest.json`.
- **DoD:** blur/skew/rotation/noise/crop/mixed PDF; lưu homography để biến đổi bbox GT; file invalid/encrypted/giới hạn có expected error; bản chụp thực nếu có chỉ từ tài liệu tổng hợp; có nhãn severity/readability trước benchmark.

### T09 — Dataset registry, split và golden freeze [P0 · 0,5 ngày]

- **Mục đích:** ngăn leakage và tái tạo benchmark.
- **Phụ thuộc:** T06–T08.
- **Files:** `data/{README.md,provenance.json,splits.json,golden_manifest.json}`, `tools/datasets/{build,verify_splits}.py`, `tests/data/test_split_integrity.py`.
- **DoD:** dev/calibration/golden tách statement family/seed và biến thể; golden 150 hoặc phạm vi 50–150 đã thống nhất; ít nhất 2 họ layout chưa dùng dựng thuật toán; checksum và manifest frozen; synthetic-only audit; golden labels không được mount vào worker.

### T10 — Evaluator baseline độc lập [P0 · 1 ngày]

- **Mục đích:** đo lỗi trước tối ưu, tránh tự chọn metric có lợi.
- **Phụ thuộc:** T03, T07.
- **Files:** `evaluation/{alignment,field_metrics,row_metrics,statement_metrics,cli}.py`, `evaluation/configs/default.yaml`, `tests/evaluation/test_metric_oracles.py`.
- **DoD:** evaluator nhận prediction JSON + GT; missing/extra/duplicate rows bị tính lỗi; wrong numeric/date không fuzzy-match thành đúng; có n/denominator; tests bằng prediction cố tình sai kiểm chứng precision/recall/exact match. Alignment không che lỗi do reorder hoặc cùng giá trị.

### T11 — Inspect tài liệu và render chuẩn [P0 · 1 ngày]

- **Mục đích:** biến PDF/ảnh thành page representation an toàn và có thông tin tọa độ.
- **Phụ thuộc:** T02–T04.
- **Files:** `backend/app/documents/{inspect,render,geometry}.py`, `tests/documents/test_geometry.py`, `tests/documents/test_inspection.py`.
- **DoD:** đo page dimensions/rotation/text/images; PDF/ảnh lỗi có error code; bbox round-trip giữa PDF/render/UI đúng trên 0°/90°/180°, cropbox và nhiều DPI; giới hạn số trang/pixel trước render; không thực thi PDF JavaScript.

### T12 — PDF token extractor và đường baseline [P0 · 1 ngày]

- **Mục đích:** lấy chữ và số trực tiếp từ nguồn nhanh, giữ provenance.
- **Phụ thuộc:** T11, T03.
- **Files:** `backend/app/extraction/{base,pdf_tokens}.py`, `tests/extraction/test_pdf_tokens.py`.
- **DoD:** token IDs ổn định trong một run; raw_text và bbox giữ nguyên; Unicode/reading order được kiểm thử; confidence thiếu không mặc định 1,0; tách extractor output khỏi GT; baseline không gọi LLM.

### T13 — Chuẩn hóa số, ngày và currency [P0 · 1 ngày]

- **Mục đích:** ngăn lỗi định dạng và giữ khác biệt missing/zero.
- **Phụ thuộc:** T03, T06.
- **Files:** `backend/app/normalization/{money,dates,text}.py`, `tests/normalization/test_money.py`, `tests/normalization/test_dates.py`.
- **DoD:** Decimal cho dấu chấm/phẩy, âm/ngoặc, currency precision; ambiguous locale phải review; ngày không hợp lệ/thiếu năm không được tự điền âm thầm; raw khác normalized; số không có source không hợp lệ trừ derived field có nhãn riêng.

### T14 — Table/row reconstruction nhiều trang [P0 · 2 ngày]

- **Mục đích:** lấy đủ giao dịch và ghép mô tả đúng.
- **Phụ thuộc:** T12, T13, T07.
- **Files:** `backend/app/extraction/{tables,rows,multipage,row_kinds}.py`, `tests/extraction/test_rows.py`, `tests/extraction/test_multipage.py`.
- **DoD:** 3 layout dev tối thiểu; multiline/multiregion, header/footer/carry-forward được phân loại; source order giữ; zero-transaction phân biệt failure; không tự dedup giao dịch giống nhau; row candidates có thể chưa map phải lưu unresolved, không bị loại âm thầm.

### T15 — Validator số dư và coverage [P0 · 1,5 ngày]

- **Mục đích:** phát hiện sai/mất dòng, phân biệt lỗi nguồn và lỗi đọc.
- **Phụ thuộc:** T13, T14.
- **Files:** `backend/app/validation/{ledger,dates,completeness,engine}.py`, `tests/validation/test_ledger.py`, `tests/validation/test_completeness.py`.
- **DoD:** per-row/period reconciliation, sign convention, sort direction, missing page/row candidates, date warnings; test cặp giao dịch bù nhau cho thấy balance-pass không phải exact-correct; thiếu opening hoặc closing trả check-unavailable; không bịa số dư; lỗi nguồn có issue riêng và không tự sửa.

### T16 — Orchestrator và CLI walking skeleton [P0 · 1 ngày]

- **Mục đích:** có luồng chạy xuyên suốt càng sớm càng tốt.
- **Phụ thuộc:** T10–T15.
- **Files:** `backend/app/pipeline/{runner,artifacts}.py`, `backend/app/cli.py`, `tests/pipeline/test_pdf_e2e.py`, `scripts/demo_cli.ps1`, `scripts/demo_cli.sh`.
- **DoD:** một lệnh input→prediction JSON+issues+summary; clean, malformed, multiline và incorrect-source cases có trạng thái đúng; artifact có version/hash; không đọc GT; baseline report lưu riêng; API/UI có thể dùng cùng pipeline.

## M2 — PDF product có thể sử dụng

### T17 — Persistence, revisions và migrations [P0 · 1 ngày]

- **Mục đích:** bảo toàn run gốc và thao tác sửa qua restart.
- **Phụ thuộc:** T03, T16.
- **Files:** `backend/app/db/{session,models,repositories}.py`, `backend/alembic/versions/0001_initial.py`, `tests/integration/test_revisions_db.py`.
- **DoD:** documents/jobs/runs/transactions/issues/reviews/audit/events; migrations up trên DB sạch; extraction snapshot bất biến; latest revision và approved snapshot tách biệt; Decimal lưu NUMERIC/string phù hợp, không float.

### T18 — Authentication và hai vai trò [P0 · 1 ngày]

- **Mục đích:** quyền thao tác phản ánh nhân viên ngân quỹ và kế toán.
- **Phụ thuộc:** T17.
- **Files:** `backend/app/auth/{sessions,permissions,routes}.py`, `backend/app/db/seed_demo.py`, `frontend/src/features/auth/LoginPage.tsx`, `tests/security/test_permissions.py`.
- **DoD:** hash password, session expiry/logout, cookie flags và CSRF nếu cookie auth; operator upload/edit/submit, accountant approve/export; unauthorized requests trả 401/403, kiểm tra file IDs và document scope; policy self-approval rõ; tài khoản demo không dùng secret cố định cho production.

### T19 — Upload, private storage và document endpoints [P0 · 1 ngày]

- **Mục đích:** nhận và phục vụ file có kiểm soát quyền/giới hạn.
- **Phụ thuộc:** T11, T17, T18.
- **Files:** `backend/app/storage/{base,local}.py`, `backend/app/api/documents.py`, `backend/app/documents/upload_policy.py`, `tests/api/test_documents.py`.
- **DoD:** extension+MIME+parser validation, generated filename, size/page/pixel limit, path traversal negative tests; read/render/download chỉ qua auth; duplicate upload được thông báo, không làm mất run riêng; source file immutable.

### T20 — Worker bền vững, progress và cancel [P0 · 1,5 ngày]

- **Mục đích:** xử lý nặng không khóa request và phục hồi sau lỗi.
- **Phụ thuộc:** T16, T17, T19.
- **Files:** `backend/app/jobs/{celery_app,tasks,service}.py`, `backend/app/api/jobs.py`, `tests/integration/test_jobs.py`.
- **DoD:** upload trả job ID; polling có stage/page/progress; bounded workers, retry/backoff/timeout; task chạy lại không nhân đôi giao dịch; stale jobs có recovery; cancel best-effort rõ; crash giữa chừng không báo succeeded; PDFium concurrency theo process boundary đã chọn.

### T21 — UI shell, inbox, upload và progress [P0 · 1,5 ngày]

- **Mục đích:** người dùng hiểu đang xử lý gì và có thể tiếp tục tác vụ sau refresh.
- **Phụ thuộc:** T05, T18–T20.
- **Files:** `frontend/src/{App.tsx,styles/tokens.css}`, `frontend/src/features/documents/{InboxPage,UploadPanel,JobProgress}.tsx`, `frontend/src/api/client.ts`, `frontend/src/router.tsx`.
- **DoD:** sample picker/upload/progress/history; lỗi có hành động retry; refresh quay lại job; bỏ polling khi rời trang; không phần trăm giả; UI trạng thái empty/partial/failed; tiếng Việt nhất quán và desktop responsive.

### T22 — Evidence viewer đồng bộ với transaction table [P0 · 2 ngày]

- **Mục đích:** kiểm tra nguồn nhanh và chính xác.
- **Phụ thuộc:** T11, T14, T21.
- **Files:** `frontend/src/features/review/{ReviewPage,DocumentViewer,EvidenceOverlay,TransactionTable}.tsx`, `frontend/src/features/review/coordinates.ts`, `frontend/src/features/review/reviewStore.ts`, `frontend/src/features/review/coordinates.test.ts`.
- **DoD:** click row/field→đúng page/vùng; zoom/rotation/HiDPI và resize không lệch; nhiều bbox cho mô tả; vùng thiếu evidence có nhãn; lazy render trang/virtualize bảng; không cần tải ảnh toàn tài liệu vào RAM một lần.

### T23 — Edit, revalidate và approval workflow [P0 · 1,5 ngày]

- **Mục đích:** sửa có trách nhiệm, không mất dữ liệu hoặc duyệt nhầm phiên bản.
- **Phụ thuộc:** T15, T17, T18, T22.
- **Files:** `backend/app/review/{service,policy}.py`, `backend/app/api/reviews.py`, `frontend/src/features/review/{FieldEditor,ValidationPanel,ApprovalBar}.tsx`, `tests/api/test_review_workflow.py`.
- **DoD:** edit lưu before/after+actor+time+reason và provenance; revalidate theo revision; optimistic locking trả conflict khi hai tab sửa; issue blocking chưa giải quyết không được approve; edit sau approve hủy approval; lỗi nguồn không giải được có thể reject hoặc exception cần lý do, không giả check-pass.

### T24 — Export chuẩn, an toàn và có provenance [P0 · 1 ngày]

- **Mục đích:** đầu ra dùng được cho bước đối chiếu tiếp theo.
- **Phụ thuộc:** T23.
- **Files:** `backend/app/export/{csv_export,xlsx_export,json_export,policy}.py`, `backend/app/api/exports.py`, `frontend/src/features/export/ExportDialog.tsx`, `tests/export/test_exports.py`.
- **DoD:** accountant xuất approved revision; draft nếu hỗ trợ phải dán nhãn riêng; row count, Decimal, date và encoding đúng; CSV/XLSX formula injection bị xử lý; metadata run/revision và audit; export cũ không đổi khi dữ liệu được sửa.

### T25 — PDF vertical-slice integration gate [P0 · 1 ngày]

- **Mục đích:** xác nhận pipeline và UX đã tích hợp thật.
- **Phụ thuộc:** T21–T24.
- **Files:** `frontend/e2e/pdf-review.spec.ts`, `tests/integration/test_pdf_workflow.py`, `docs/qa/m2-evidence.md`.
- **DoD:** operator login→upload→row nguồn→sửa→submit; accountant approve→export; restart giữ revision; unauthorized export bị chặn; partial job hiển thị rõ; output export khớp approved snapshot. Chỉ qua gate mới mở rộng nhiều model.

## M3 — Scan, router, thích ứng layout

### T26 — OCR adapter và preprocessing giữ tọa độ [P0 · 2 ngày]

- **Mục đích:** hỗ trợ ảnh/scan và khôi phục evidence về ảnh gốc.
- **Phụ thuộc:** T02, T08, T11, T12.
- **Files:** `backend/app/ocr/{base,preprocess,local_adapter}.py`, `backend/app/ocr/provider_adapter.py` nếu được chọn, `tests/ocr/test_transforms.py`, `tests/ocr/test_scan_extraction.py`.
- **DoD:** backend đã chọn trả token+bbox+score; rotation/deskew mapping ngược đúng; raw OCR không bị LLM ghi đè; scan unreadable trả needs_review/failed có lý do; runtime model cache/download được tài liệu hóa; số liệu tiếng Việt trên dev set được đo.

### T27 — Router theo chất lượng từng trang [P0 · 1 ngày]

- **Mục đích:** dùng parser nhanh khi đủ chất lượng, OCR khi cần.
- **Phụ thuộc:** T12, T26, T15.
- **Files:** `backend/app/routing/{features,policy}.py`, `backend/app/pipeline/runner.py`, `configs/routing.yaml`, `tests/routing/test_routes.py`.
- **DoD:** feature text coverage/garbage/order/image content; threshold dev-tuned, versioned; mixed PDF chọn theo trang; fake text layer không đương nhiên đi parser; fallback có tối đa số lần và cost budget; route/reason được ghi telemetry.

### T28 — LLM chọn token và schema mapping [P0 · 1,5 ngày]

- **Mục đích:** thích ứng cột/ghép dòng khó mà không tái gõ số bằng mô hình.
- **Phụ thuộc:** T03, T14, T26.
- **Files:** `backend/app/llm/{base,provider,schemas,token_mapping}.py`, `backend/app/prompts/statement_mapping.md`, `tests/llm/test_evidence_constraints.py`, `tests/fixtures/llm/manifest.json`.
- **DoD:** output token IDs/row mappings; code copy source→parse; unknown token/forged amount/schema error bị reject; thiếu evidence bắt buộc review; timeout/retry bounded; prompt coi document text là data; fixtures chỉ synthetic, retry cũng tính cost. Nếu local-only, dùng local provider hoặc ghi nhánh rules với hỗ trợ layout hẹp hơn.

### T29 — Template config và onboarding layout [P1 · 1,5 ngày]

- **Mục đích:** thêm bố cục mới mà không sửa source code.
- **Phụ thuộc:** T14, T27, T28.
- **Files:** `backend/app/templates/{schema,registry,match,runner}.py`, `configs/templates/{alpha,beta,gamma}.yaml`, `tools/templates/validate.py`, `tests/templates/test_onboarding.py`.
- **DoD:** config định nghĩa anchor/column aliases/date/locale/order/row kinds và được validate; unknown layout có fallback/review; demo thêm layout thứ 4 chỉ bằng config và đạt regression trên các layout cũ; version/hash của template lưu theo run. Không cần UI template studio ở core.

### T30 — Khoanh vùng dòng/đoạn gây lệch [P0 · 1 ngày]

- **Mục đích:** người duyệt tìm đúng nơi cần kiểm tra.
- **Phụ thuộc:** T15, T22, T26.
- **Files:** `backend/app/validation/localize.py`, `frontend/src/features/review/{IssueNavigator,BalanceTrace}.tsx`, `tests/validation/test_localize.py`.
- **DoD:** chỉ ra boundary đầu tiên lệch và nhóm nghi ngờ; hiển thị expected vs observed, liên kết evidence; ca thiếu opening/descending/đổi trang không bị chỉ sai chắc chắn; không tự sửa số hoặc tuyên bố biết nguyên nhân khi chỉ có giả thuyết.

### T31 — Scan/mixed E2E gate [P0 · 1 ngày]

- **Mục đích:** hoàn thành phần scan bắt buộc của đề.
- **Phụ thuộc:** T25, T26, T27, T28, T30; T29 là mở rộng tùy chọn.
- **Files:** `frontend/e2e/scan-review.spec.ts`, `tests/integration/test_mixed_workflow.py`, `docs/qa/m3-evidence.md`.
- **DoD:** scan/mixed→review→approve→export chạy thật; rotated bbox đúng; OCR fail một trang không mất dấu giao dịch; ảnh đọc được và unreadable có hành vi khác nhau; router không bypass validation.

## M4 — Accuracy, calibration, hiệu năng và UX

### T32 — Feature risk và confidence calibration [P0 · 1,5 ngày]

- **Mục đích:** độ tin cậy có bằng chứng thực nghiệm và ngưỡng review có cơ sở.
- **Phụ thuộc:** T09, T10, T31.
- **Files:** `backend/app/confidence/{features,calibration,policy}.py`, `evaluation/calibrate.py`, `artifacts/calibration/README.md`, `configs/confidence.yaml`, `tests/confidence/test_risk_policy.py`.
- **DoD:** feature OCR/evidence/layout/validation; không dùng GT hoặc LLM self-score khi inference; fit chỉ calibration, threshold khóa trước golden; artifact versioned; risk–coverage và reliability đo trên unseen subset; chưa đủ n thì confidence null hoặc review, không gán 100% vì balance-pass.

### T33 — Final evaluation runner và thống kê [P0 · 1,5 ngày]

- **Mục đích:** báo cáo trung thực extraction trước HITL và tác động sau duyệt.
- **Phụ thuộc:** T09, T10, T32.
- **Files:** `evaluation/{run_benchmark,stratify,statistics,report}.py`, `evaluation/configs/release.yaml`, `reports/README.md`, `tests/evaluation/test_denominators.py`.
- **DoD:** per field/row/document/layout/quality; extra/missing/unsupported cũng có denominator; confident-wrong định nghĩa rõ n auto/total, risk CI và document-level summary; balance consistency tách GT correctness; pre/post HITL tách; report lưu dataset/run/model/config hashes; không tune theo golden.

### T34 — Baseline comparison và ablation [P1 · 1 ngày]

- **Mục đích:** chứng minh module tăng accuracy/tốc độ có đáng chi phí.
- **Phụ thuộc:** T27, T28, T33.
- **Files:** `evaluation/{baselines,ablation}.py`, `evaluation/configs/ablations.yaml`, `docs/research/experiment-protocol.md`.
- **DoD:** ít nhất rules/parser+OCR vs hybrid; VLM chủ đạo nếu có ngân sách và đảm bảo alignment; cùng corpus/split; router on/off, LLM fallback on/off, validation on/off; ghép so sánh theo document, ghi uncertainty và retry; không khẳng định ưu việt nếu chưa đủ n.

### T35 — Usage, cost và báo cáo tháng [P0 · 1 ngày]

- **Mục đích:** chi phí trang/tài liệu/tháng truy được tới usage thật.
- **Phụ thuộc:** T20, T26–T28.
- **Files:** `backend/app/telemetry/{usage,cost,logging}.py`, `configs/pricing.yaml`, `evaluation/cost_report.py`, `tests/telemetry/test_cost.py`.
- **DoD:** model/version/date/currency input/output/image/OCR usage, retry/cache đều tính; giá thiếu hiện unpriced; tách API cost và compute estimate/human review; kịch bản 1k/10k/100k trang tháng có scan ratio/page count rõ, không coi local inference miễn phí vận hành.

### T36 — Profiling và tối ưu hiệu năng [P0 · 1,5 ngày]

- **Mục đích:** nhanh và ổn định theo tải có giới hạn.
- **Phụ thuộc:** T31, T35.
- **Files:** `evaluation/performance/{load,profile}.py`, `backend/app/jobs/limits.py`, `backend/app/pipeline/cache.py`, `frontend/src/features/review/viewerCache.ts`, `docs/qa/performance.md`.
- **DoD:** baseline trước/sau P50/P95, cold/warm, 1/5/10 concurrent jobs, CPU/RAM/queue wait; bounded rendering/OCR; cache key theo document+pipeline+template/model version và scope, có TTL; vượt capacity báo queued/rate-limit; tối ưu không giảm accuracy trên regression set.

### T37 — Usability test và polish [P0 · 1,5 ngày]

- **Mục đích:** xác nhận người dùng thực sự duyệt nhanh, ít nhầm.
- **Phụ thuộc:** T05, T25, T31.
- **Files:** `docs/ux/{test-results,findings}.md`, `frontend/src/features/review/{KeyboardHelp,ReviewQueue}.tsx`, `frontend/src/styles/{tokens.css,accessibility.css}`, `frontend/e2e/keyboard.spec.ts`.
- **DoD:** ≥5 người thử; document/task order đối trọng khi so với không evidence, không cho nhớ cùng tài liệu; ghi n/timing/errors; sửa lỗi nghiêm trọng; keyboard/focus/tab labels/không chỉ dùng màu; monetary formatting rõ, không auto-approve theo Enter nhầm.

### T38 — Dashboard chất lượng và vận hành [P1 · 1 ngày]

- **Mục đích:** accountant theo dõi pending/issues và số đo có ngữ cảnh.
- **Phụ thuộc:** T23, T33, T35.
- **Files:** `backend/app/api/metrics.py`, `frontend/src/features/metrics/{DashboardPage,MetricCards}.tsx`, `tests/api/test_metrics_scope.py`.
- **DoD:** queue/fail/review/route/latency/cost; không gọi operational pass rate là accuracy khi không có GT; benchmark metrics hiện dataset/version/n riêng; scope quyền áp dụng cho thống kê; không cần triển khai full observability platform.

## M5 — Hardening và bàn giao

### T39 — Data lifecycle và security regression [P0 · 1,5 ngày]

- **Mục đích:** hoàn thiện kiểm soát file và quyền đã bắt đầu ở T18–T19.
- **Phụ thuộc:** T18–T24, T26, T35.
- **Files:** `backend/app/security/{retention,redaction,rate_limit}.py`, `tests/security/{test_object_access,test_retention,test_logs,test_upload_limits}.py`, `docs/security/data-flow.md`, `docs/security/demo-policy.md`.
- **DoD:** cross-user/document access theo policy bị chặn; original/render/OCR/cache/export xóa theo TTL không xóa active approved snapshot trái chính sách; log chứa metadata không payload; secret scan/dependency report được review; PDF timeout/oversized image/prompt injection có negative tests. Public demo sample-only hoặc có quota và cảnh báo dữ liệu tổng hợp.

### T40 — Fault recovery và tích hợp release [P0 · 1 ngày]

- **Mục đích:** lỗi hạ tầng không thành mất dữ liệu hoặc thành công giả.
- **Phụ thuộc:** T20, T23, T31, T39.
- **Files:** `tests/resilience/{test_worker_crash,test_provider_fail,test_idempotency}.py`, `frontend/e2e/failure-recovery.spec.ts`, `docs/qa/release-checklist.md`.
- **DoD:** kill worker/retry duplicate/provider 429/timeout/Redis gián đoạn/mất mạng frontend/double approve đều có outcome xác định; no duplicate rows; revision conflict đúng; report lỗi từng trang và có retry; test replay offline gắn nhãn, không tính latency live.

### T41 — Docker deployment và clone sạch [P0 · 1 ngày]

- **Mục đích:** hội đồng/người khác dựng được hệ thống.
- **Phụ thuộc:** T04, T20, T25, T31, T39.
- **Files:** `backend/Dockerfile`, `frontend/Dockerfile`, `compose.yaml`, `deploy/{nginx.conf,README.md}`, `scripts/{bootstrap.ps1,bootstrap.sh,smoke.ps1,smoke.sh}`, `.github/workflows/release.yml`.
- **DoD:** API/worker/Postgres/Redis/web healthcheck; migrations và demo accounts chạy idempotent; OCR weights sẵn hoặc download có checksum/license; secrets ngoài image; TLS khi deploy public; smoke clone sạch cả PDF+scan; server resource limits được ghi; không cần GPU nếu cấu hình CPU/API đã chọn.

### T42 — Tài liệu, demo và báo cáo nộp [P0 · 1,5 ngày]

- **Mục đích:** kết quả có thể review và giới hạn được giải thích rõ.
- **Phụ thuộc:** T33, T35, T36, T37, T39, T40, T41; T34 và T38 tùy chọn.
- **Files:** `README.md`, `docs/{USER_GUIDE,ARCHITECTURE,OPERATIONS}.md`, `docs/submission/{report,demo-script,limitations,rubric-evidence}.md`, `docs/legal/dependencies.md`.
- **DoD:** hướng dẫn start/E2E/test/eval, demo clean+scan+balance error+correct+approve+export, security/data policy, cost assumptions, synthetic-to-real gap; report có actual values/link artifacts, không điền số giả; video dự phòng và ownership repo rõ; final API/config/model version tương ứng release.

### T43 — Release candidate và rehearsal [P0 · 1 ngày]

- **Mục đích:** chốt bản nộp có thể lặp lại trên máy khác.
- **Phụ thuộc:** T40–T42.
- **Files:** `docs/submission/release-record.md`, `CHANGELOG.md`, `docs/qa/final-signoff.md`.
- **DoD:** người không viết module tự clone và chạy; CI và gates pass; báo cáo unresolved issues/severity; demo link được kiểm tra; artifacts/checksums/tag dự kiến ghi lại. Publish/tag/upload thực hiện theo kênh và quyền đã thống nhất khi triển khai; kế hoạch này chưa thực hiện các hành động đó.

## M6 — Nâng cao sau khi đủ core

### T44 — Gợi ý sửa có evidence [P2 · 1,5 ngày]

- **Mục đích:** giảm thao tác với chữ số OCR mơ hồ hoặc dòng thiếu.
- **Phụ thuộc:** T30, T32, T37.
- **Files:** `backend/app/validation/suggestions.py`, `frontend/src/features/review/SuggestionPanel.tsx`, `tests/validation/test_suggestions.py`.
- **DoD:** chỉ đề xuất candidate có nguồn, người duyệt chọn; không giải phương trình rồi tự điền vào dữ liệu gốc; đo precision gợi ý và thời gian duyệt, false suggestions; decline giữ nguyên dữ liệu.

### T45 — Correction feedback và template regression [P2 · 2 ngày]

- **Mục đích:** lần sửa giúp nhận biết lỗi lặp lại có kiểm chứng.
- **Phụ thuộc:** T23, T29, T33.
- **Files:** `backend/app/templates/{proposals,regression}.py`, `frontend/src/features/templates/ProposalReview.tsx`, `evaluation/correction_loop.py`, `tests/templates/test_version_rollback.py`.
- **DoD:** đề xuất config version mới, accountant duyệt trước dùng; before/after trên held-out mới và regression các layout khác; rollback tái chạy được; không dùng chính tài liệu sửa để chứng minh cải thiện.

### T46 — Chuẩn bị pilot doanh nghiệp [P2 · 1,5 ngày]

- **Mục đích:** xác định khoảng cách từ demo tổng hợp đến môi trường thực tế.
- **Phụ thuộc:** T43.
- **Files:** `docs/pilot/{requirements,data-agreement-template,deployment-options,validation-protocol}.md`, `backend/app/storage/s3.py` chỉ nếu pilot chọn S3.
- **DoD:** xác định dữ liệu được phép xử lý, roles, deployment local/cloud, retention, provider terms, benchmark thực có kiểm soát, tiêu chí stop/go; không tải dữ liệu thật hoặc kết nối ngân hàng trong task chuẩn bị tài liệu.

## Quy tắc quản lý triển khai

1. Chuyển từng task thành issue với owner, estimate, dependency, acceptance evidence và trạng thái TODO/IN_PROGRESS/REVIEW/DONE/BLOCKED.
2. Mỗi người giữ tối đa một task triển khai chính; sửa contract qua PR nhỏ có consumer review.
3. Sau mỗi milestone chạy demo E2E từ UI/CLI, không chỉ unit tests; ghi version và lỗi còn lại.
4. Chỉ chạy full golden sau freeze pipeline/calibration; trước đó dùng dev regression và calibration đúng vai trò.
5. Task vượt timebox: cắt tính năng P1/P2, điều chỉnh scope công khai; không bỏ error handling, evidence, scan hoặc metric để giữ lịch.
6. Dùng effort ước tính để lập lịch sau khi biết nguồn lực. Thời gian learning/integration có thể tăng 30–50% với thành viên mới frontend/OCR; không coi estimate là cam kết thời hạn.
