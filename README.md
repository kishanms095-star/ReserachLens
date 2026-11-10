# ResearchLens
**ResearchLens: A Comparative Research Paper Analysis and Evidence-Based Framework**

A local-first Flask application for uploading text-based research PDFs, generating structured candidate extractions with page-linked passages, reviewing evidence, comparing evidence coverage across papers, and exporting reports.

> **Accuracy boundary:** the included extractor is a transparent heading/keyword candidate retriever, not a validated scientific information-extraction model. It marks uncertain/missing fields explicitly and requires human review. It does not claim semantic understanding, validated research-gap discovery, or an accuracy percentage. Optional Sentence Transformers support is isolated and is not enabled by default.

## Features
- Registration, login, logout, password change, Werkzeug password hashing, Flask-Login and CSRF protection.
- Role-protected administrator overview, user activation/deactivation and login audit records.
- User-scoped paper storage and access checks; PDFs are stored outside `static/`.
- Multi-file PDF upload, PDF parsing with PyMuPDF, page-level text extraction and scanned/encrypted/empty PDF rejection.
- Candidate fields for title, authors, year, abstract, keywords, objectives, questions, methodology, algorithms, dataset, setup, metrics, results, limitations and future scope.
- Passage, PDF page, detected heading, method, confidence and review status attached to candidate fields.
- Manual verification / incorrect marking and correction note.
- Evidence coverage comparison and JSON-backed evidence matrix export to CSV; individual and comparison PDF exports.
- pytest suite and a Windows double-click launcher.

## Stack
Python 3.10+, Flask, Flask-SQLAlchemy, Flask-Login, Flask-WTF, SQLite, PyMuPDF, ReportLab, Bootstrap 5.3.3. PostgreSQL can be used by setting `DATABASE_URL` to a PostgreSQL SQLAlchemy URI and installing a suitable PostgreSQL driver.

## Quick start — Windows
1. Install Python 3.10 or newer from https://www.python.org/downloads/. During installation, enable **Add Python to PATH**.
2. Extract the ZIP to a writable folder (for example `C:\Projects\ResearchLens`).
3. Double-click `start.bat`. It creates `.venv`, installs `requirements.txt`, creates `.env` from `.env.example` if missing, initializes tables without deleting existing data, starts Flask on `0.0.0.0:5000`, and opens the local app in the default browser (Chrome when available).
4. Open `http://127.0.0.1:5000`.

The first dependency installation needs an internet connection. Keep the terminal window open while using the application. Close it with Ctrl+C to stop the server.

## VS Code setup
Open the extracted `ResearchLens` folder (not just an individual file) in VS Code. Open Terminal → New Terminal:
```powershell
py -3 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
Copy-Item .env.example .env
python scripts/init_db.py
python run.py
```
If PowerShell blocks activation, run `Set-ExecutionPolicy -Scope Process Bypass` in that terminal, then activate again. Command Prompt equivalent:
```bat
py -3 -m venv .venv
.venv\Scripts\activate.bat
python -m pip install -r requirements.txt
copy .env.example .env
python scripts\init_db.py
python run.py
```

## Environment configuration
Edit `.env` before non-test use. Generate a strong secret key, for example:
```powershell
python -c "import secrets; print(secrets.token_urlsafe(48))"
```
Set `SECRET_KEY` to the generated value. Optional: set `MAX_UPLOAD_MB`, `DATABASE_URL`, `UPLOAD_FOLDER` and `REPORT_FOLDER`. Never commit `.env`.

## Create an administrator
Set `ADMIN_USERNAME`, `ADMIN_EMAIL`, and a unique `ADMIN_PASSWORD` (minimum 14 characters) in `.env`, then run:
```powershell
python scripts/create_admin.py
```
The script refuses to overwrite an existing account. No default admin account or password is embedded in source. Remove the admin password from `.env` after provisioning if desired.

## Mobile access on the same Wi-Fi
- Connect laptop and phone to the same trusted Wi-Fi network.
- On Windows run `ipconfig` and note the laptop's active Wi-Fi **IPv4 Address** (for example `192.168.1.20`).
- On the phone open `http://192.168.1.20:5000` using your actual address.
- If blocked, allow Python through Windows Defender Firewall on **Private networks only**, or create a narrowly scoped inbound TCP 5000 rule for the Private profile.
- This is LAN access only, not public deployment. Do not expose port 5000 to the internet.

## Testing
```powershell
.\.venv\Scripts\Activate.ps1
python -m pytest -q
```
The tests use isolated temporary SQLite databases. The suite covers basic registration/login/logout, password hashing, failed-login audit, admin authorization, invalid upload rejection, missing-field representation, evidence helper behavior, comparison selection guard and login-protected export. The test suite does **not** constitute full penetration testing or end-to-end browser QA.

## Architecture
- `app/__init__.py`: application factory, configuration, blueprint registration and error handlers.
- `app/models.py`: SQLAlchemy entities and relationships.
- `app/auth/`: account lifecycle and login audit.
- `app/admin/`: role-protected admin pages.
- `app/papers/`: upload, library, ownership checks, PDF access and deletion.
- `app/analysis/`: evidence review, comparison, CSV and PDF exports.
- `app/services/`: PDF parsing, cleaning, section detection, field candidate retrieval, optional semantic matcher and report generation.
- `app/templates/`, `app/static/`: Bootstrap UI, CSS and JavaScript.
- `scripts/`: safe DB initialization and admin provisioning.
- `tests/`: pytest coverage.

## Data and security notes
- SQLite file defaults to `data/researchlens.db`; uploads and reports live under `data/`.
- User ownership is checked on every paper/evidence/comparison route.
- Uploaded files are random UUID names and are never served from a public static directory.
- CSRF protection is enabled on form routes. Passwords use Werkzeug's password hashing.
- Login records include attempted identity, timestamp, success/failure category and remote IP. IP addresses are personal data: restrict admin access, set an appropriate retention policy and disclose logging to users.
- The built-in development server is intended for local evaluation only. For deployment, use a production WSGI server, HTTPS, secure cookie settings, migrations, rate limiting, backups, antivirus/file scanning and a formal privacy policy.
- Bootstrap is loaded from a CDN; offline UI styling requires vendoring Bootstrap locally.

## Known limitations / next steps
1. OCR for scanned PDFs is not implemented; such files are rejected with a clear message.
2. Password-protected PDFs are rejected; password prompting is not implemented.
3. Extraction is heuristic candidate retrieval. PDF layouts vary; title/authors/year and section boundary detection can be wrong. Verify every result against the original PDF.
4. Sentence Transformers is optional and not installed by default. The baseline clearly identifies its retrieval method; it does not pretend semantic ranking is active.
5. Comparison is an evidence-coverage matrix. Similarity, contradiction detection, methodological equivalence, causal synthesis and research-gap generation are deliberately not fabricated.
6. No production database migration history is bundled yet; the documented `create_all()` initialization preserves existing tables but does not migrate changed schemas. Use Flask-Migrate/Alembic before schema evolution.
7. Account lockout, email verification, password reset, rate limiting, malware scanning, retention automation and production-grade deployment are future security tasks.
8. Browser-based manual QA, actual Chrome launch, and same-Wi-Fi phone testing depend on the target Windows machine/network and must be verified there.

## Troubleshooting
- **Python not found:** install Python 3.10+ and enable PATH; reopen terminal.
- **Dependency installation fails:** check internet/proxy and rerun `pip install -r requirements.txt`.
- **Port 5000 busy:** stop the other process or set `PORT` in the environment before launch.
- **Phone cannot connect:** confirm same Wi-Fi, correct IPv4, server still running, Private firewall permission and no guest-network client isolation.
- **No extracted text:** the file may be scanned; OCR is a future extension.
- **Admin creation says account exists:** use a different username/email; the script intentionally will not change existing accounts.

## Evaluation framework
For reproducible evaluation, create a separate annotation dataset (never mix it with user uploads) containing paper identifier, field key, gold answer, gold evidence passage, gold PDF page and annotator. Compare system output to gold records to calculate field-level precision/recall/F1, evidence retrieval hit rate, page-reference accuracy and missing-field detection. Comparison correctness requires a separately annotated set of pairwise claims. No accuracy score is asserted until such a dataset is evaluated.
