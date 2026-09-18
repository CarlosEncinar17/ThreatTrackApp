-- =====================================================================
-- ThreatTrackApp - datos de ejemplo
-- Dos clientes, sus activos y consultas, y alertas de ejemplo de todas las fuentes.
-- Fechas desplazadas a 2026-09 con tools/shift_seed_dates.py para que los dashboards muestren datos.
-- =====================================================================

BEGIN;
INSERT INTO public.customers ("name", registered_at, is_active, notes)
VALUES
('TechSolutions', '2026-09-07 10:26:19.368', true, NULL),
('SecureFuture', '2026-09-08 09:00:00.000', true, NULL);

-- Insertamos los estados posibles para las alertas
INSERT INTO public.alert_states ("name") VALUES 
('open'),
('in_progress'),
('resolved'),
('false_positive'),
('duplicated');


-- Insertamos las criticidades posibles para las alertas
INSERT INTO public.alert_severities ("name") VALUES 
('critical'),
('high'),
('medium'),
('low'),
('informative'),
('unknown');

-- Insertamos los nombres de los servicios en la tabla 
INSERT INTO public.service_catalog ("name") values 
('credentials'),
('information'),
('defacement'),
('phishing'),
('mon_domains'),
('categorization'),
('carding'),
('mon_sist_vuln'),
('fraud_app'),
('hacktivism'),
('vip_vap');


INSERT INTO public.scan_runs (module_name, run_started_at, run_finished_at, notes)
VALUES('Typosquatting', '2026-09-07 08:04:55.269', '2026-09-07 04:06:38.589', NULL);
INSERT INTO public.scan_runs (module_name, run_started_at, run_finished_at, notes)
VALUES('Google', '2026-09-07 07:05:03.205', '2026-09-07 04:06:38.589', NULL);
INSERT INTO public.scan_runs (module_name, run_started_at, run_finished_at, notes)
VALUES('Twitter', '2026-09-07 04:06:25.840', '2026-09-07 04:06:38.589', NULL);
INSERT INTO public.scan_runs (module_name, run_started_at, run_finished_at, notes)
VALUES('GitLab', '2026-09-07 02:30:56.478', '2026-09-07 02:30:56.613', NULL);
INSERT INTO public.scan_runs (module_name, run_started_at, run_finished_at, notes)
VALUES('Git', '2026-09-07 02:22:11.410', '2026-09-07 02:22:22.991', NULL);
INSERT INTO public.scan_runs (module_name, run_started_at, run_finished_at, notes)
VALUES('Cert', '2026-09-07 01:12:00.929', '2026-09-07 01:14:11.342', NULL);
INSERT INTO public.scan_runs (module_name, run_started_at, run_finished_at, notes)
VALUES('Intelx', '2026-09-07 01:12:00.929', '2026-09-07 01:14:11.342', NULL);






INSERT INTO public.telegram_channels (channel_name, added_at, is_active, notes)
VALUES
('TechSolutions_Support', '2026-09-07 10:20:30.400', true, NULL),
('TechSolutions_Security', '2026-09-07 14:35:50.123', true, NULL),
('TechSolutions_IT', '2026-09-07 08:15:45.567', true, NULL),
('TechSolutions_DevOps', '2026-09-07 12:00:20.789', true, NULL),
('TechSolutions_Admin', '2026-09-07 09:45:33.256', true, NULL),
('TechSolutions_Engineering', '2026-09-07 11:25:40.987', true, NULL),
('TechSolutions_Operations', '2026-09-07 16:50:12.654', true, NULL),
('TechSolutions_Finance', '2026-09-07 14:30:05.321', true, NULL),
('TechSolutions_HR', '2026-09-07 13:15:22.789', true, NULL),
('TechSolutions_Marketing', '2026-09-07 17:40:55.432', true, NULL);





-------------------------------------------- A PARTIR DE AQUI INSERCIONES A TABLAS CON DEPENDENCIAS EN ORDEN ------------------------

INSERT INTO public.customer_service_subscriptions (customer_id, defacement_enabled, github_enabled, gitlab_enabled, google_enabled, intelx_enabled, shodan_enabled, telegram_enabled, twitter_enabled, typosquatting_enabled, certificates_enabled, blocklist_enabled, notes)
VALUES
(1, true, true, true, true, true, true, true, true, true, true, true, NULL),
(2, true, true, true, true, true, true, true, true, true, true, true, NULL);



INSERT INTO public.monitored_domains (domain_name, added_at, customer_id, is_active, notes)
VALUES 
('techsolutions.com', '2026-09-08 09:00:00.000', 1, true, NULL),
('techsolutions.io', '2026-09-09 10:15:32.123', 1, false, NULL),
('techsolutions.net', '2026-09-10 11:25:45.456', 1, true, NULL),
('techsolutions.org', '2026-09-11 12:35:54.789', 1, true, NULL),
('tech-solutions.co', '2026-09-12 13:45:23.001', 1, true, NULL),
('techsolutions.tech', '2026-09-13 14:55:12.345', 1, false, NULL),
('techsolutions.biz', '2026-09-14 15:05:56.789', 1, true, NULL),
('solutions4tech.com', '2026-09-15 16:15:32.654', 1, true, NULL),
('mysolutions.tech', '2026-09-16 17:25:45.987', 1, true, NULL),
('solutionshub.net', '2026-09-17 18:35:23.123', 1, false, NULL),
('securefuture.com', '2026-09-08 09:30:00.000', 2, true, NULL),
('securefuture.io', '2026-09-09 10:45:32.123', 2, false, NULL),
('securefuture.net', '2026-09-10 11:55:45.456', 2, true, NULL),
('securefuture.org', '2026-09-11 12:15:54.789', 2, true, NULL),
('future-secure.co', '2026-09-12 13:25:23.001', 2, false, NULL),
('securefuture.tech', '2026-09-13 14:35:12.345', 2, true, NULL),
('securefuture.biz', '2026-09-14 15:45:56.789', 2, true, NULL),
('futuresecured.com', '2026-09-15 16:55:32.654', 2, false, NULL),
('mysafehub.tech', '2026-09-16 17:05:45.987', 2, true, NULL),
('securedhub.net', '2026-09-17 18:15:23.123', 2, true, NULL);



INSERT INTO public.github_commit_alerts (domain_id, repository, author_name, author_email, commit_hash, url, detected_at, committed_at, is_analyzed, customer_id, notes, state_id, severity_id)
VALUES 
(1, 'https://github.com/johndoe/project-x/commit/a1b2c3d4e5f67890', 'John Doe', 'johndoe@gmail.com', 'a1b2c3d4e5f67890', 'https://api.github.com/repos/johndoe/project-x/git/commits/a1b2c3d4e5f67890', '2026-09-08 12:34:56.789', '2026-09-02 10:00:00.000', false, 1, NULL, 1, 3), 
(2, 'https://github.com/janesmith/secureapp/commit/b2c3d4e5f67890a1', 'Jane Smith', 'janesmith@gmail.com', 'b2c3d4e5f67890a1', 'https://api.github.com/repos/janesmith/secureapp/git/commits/b2c3d4e5f67890a1', '2026-09-09 11:23:45.678', '2026-09-02 11:15:00.000', false, 1, NULL, 2, 2), 
(3, 'https://github.com/bobmartin/infosec/commit/c3d4e5f67890a1b2', 'Bob Martin', 'bobmartin@gmail.com', 'c3d4e5f67890a1b2', 'https://api.github.com/repos/bobmartin/infosec/git/commits/c3d4e5f67890a1b2', '2026-09-10 14:56:23.123', '2026-09-03 09:45:00.000', false, 1, NULL, 3, 4), 
(4, 'https://github.com/alicejohnson/data-leak/commit/d4e5f67890a1b2c3', 'Alice Johnson', 'alicejohnson@gmail.com', 'd4e5f67890a1b2c3', 'https://api.github.com/repos/alicejohnson/data-leak/git/commits/d4e5f67890a1b2c3', '2026-09-11 16:12:34.567', '2026-09-03 12:30:00.000', false, 1, NULL, 4, 5), 
(5, 'https://github.com/charliebrown/vulnerable-app/commit/e5f67890a1b2c3d4', 'Charlie Brown', 'charliebrown@gmail.com', 'e5f67890a1b2c3d4', 'https://api.github.com/repos/charliebrown/vulnerable-app/git/commits/e5f67890a1b2c3d4', '2026-09-12 18:45:12.345', '2026-09-03 14:15:00.000', false, 1, NULL, 2, 1), 
(6, 'https://github.com/davidclark/security-flaw/commit/f67890a1b2c3d4e5', 'David Clark', 'davidclark@gmail.com', 'f67890a1b2c3d4e5', 'https://api.github.com/repos/davidclark/security-flaw/git/commits/f67890a1b2c3d4e5', '2026-09-13 20:23:45.678', '2026-09-04 16:00:00.000', false, 1, NULL, 3, 3),
(7, 'https://github.com/evelynadams/hack-repo/commit/67890a1b2c3d4e5f', 'Evelyn Adams', 'evelynadams@gmail.com', '67890a1b2c3d4e5f', 'https://api.github.com/repos/evelynadams/hack-repo/git/commits/67890a1b2c3d4e5f', '2026-09-14 21:34:56.789', '2026-09-04 17:30:00.000', false, 1, NULL, 5, 4), 
(8, 'https://github.com/franklinwhite/exploit/commit/7890a1b2c3d4e5f6', 'Franklin White', 'franklinwhite@gmail.com', '7890a1b2c3d4e5f6', 'https://api.github.com/repos/franklinwhite/exploit/git/commits/7890a1b2c3d4e5f6', '2026-09-15 22:45:12.345', '2026-09-04 18:45:00.000', false, 1, NULL, 4, 2), 
(9, 'https://github.com/gracelee/pentest/commit/890a1b2c3d4e5f67', 'Grace Lee', 'gracelee@gmail.com', '890a1b2c3d4e5f67', 'https://api.github.com/repos/gracelee/pentest/git/commits/890a1b2c3d4e5f67', '2026-09-16 23:56:23.123', '2026-09-07 19:00:00.000', false, 1, NULL, 3, 3), 
(10, 'https://github.com/henryjames/phishing/commit/90a1b2c3d4e5f678', 'Henry James', 'henryjames@gmail.com', '90a1b2c3d4e5f678', 'https://api.github.com/repos/henryjames/phishing/git/commits/90a1b2c3d4e5f678', '2026-09-17 23:59:59.999', '2026-09-05 20:00:00.000', false, 1, NULL, 1, 5),
(11, 'https://github.com/marksmith/securefuture/commit/abc123def456ghi789', 'Mark Smith', 'marksmith@securefuture.com', 'abc123def456ghi789', 'https://api.github.com/repos/marksmith/securefuture/git/commits/abc123def456ghi789', '2026-09-08 12:00:00.000', '2026-09-03 10:00:00.000', false, 2, NULL, 2, 3),
(12, 'https://github.com/annbrown/cybertools/commit/def456ghi789abc123', 'Ann Brown', 'annbrown@securefuture.com', 'def456ghi789abc123', 'https://api.github.com/repos/annbrown/cybertools/git/commits/def456ghi789abc123', '2026-09-09 13:15:30.000', '2026-09-03 11:00:00.000', false, 2, NULL, 3, 2),
(13, 'https://github.com/johndoe/ai-secure/commit/ghi789abc123def456', 'John Doe', 'johndoe@securefuture.com', 'ghi789abc123def456', 'https://api.github.com/repos/johndoe/ai-secure/git/commits/ghi789abc123def456', '2026-09-10 14:30:00.000', '2026-09-03 12:00:00.000', false, 2, NULL, 4, 4),
(14, 'https://github.com/emilywhite/securityscanner/commit/jkl456mno789pqr123', 'Emily White', 'emilywhite@securefuture.com', 'jkl456mno789pqr123', 'https://api.github.com/repos/emilywhite/securityscanner/git/commits/jkl456mno789pqr123', '2026-09-11 15:45:00.000', '2026-09-04 13:00:00.000', false, 2, NULL, 5, 5),
(15, 'https://github.com/robertblack/securedata/commit/mno789pqr123stu456', 'Robert Black', 'robertblack@securefuture.com', 'mno789pqr123stu456', 'https://api.github.com/repos/robertblack/securedata/git/commits/mno789pqr123stu456', '2026-09-12 16:00:00.000', '2026-09-04 14:00:00.000', false, 2, NULL, 1, 1),
(16, 'https://github.com/sarahgreen/datashield/commit/pqr123stu456vwx789', 'Sarah Green', 'sarahgreen@securefuture.com', 'pqr123stu456vwx789', 'https://api.github.com/repos/sarahgreen/datashield/git/commits/pqr123stu456vwx789', '2026-09-13 17:15:00.000', '2026-09-04 15:00:00.000', false, 2, NULL, 3, 2),
(17, 'https://github.com/michaelblue/cyberdefense/commit/stu456vwx789yz123', 'Michael Blue', 'michaelblue@securefuture.com', 'stu456vwx789yz123', 'https://api.github.com/repos/michaelblue/cyberdefense/git/commits/stu456vwx789yz123', '2026-09-14 18:30:00.000', '2026-09-05 16:00:00.000', false, 2, NULL, 2, 4),
(18, 'https://github.com/jessicared/networkmonitor/commit/vwx789yz123abc456', 'Jessica Red', 'jessicared@securefuture.com', 'vwx789yz123abc456', 'https://api.github.com/repos/jessicared/networkmonitor/git/commits/vwx789yz123abc456', '2026-09-15 19:45:00.000', '2026-09-05 17:00:00.000', false, 2, NULL, 4, 3),
(19, 'https://github.com/charliegray/vulnscanner/commit/yz123abc456def789', 'Charlie Gray', 'charliegray@securefuture.com', 'yz123abc456def789', 'https://api.github.com/repos/charliegray/vulnscanner/git/commits/yz123abc456def789', '2026-09-16 20:00:00.000', '2026-09-05 18:00:00.000', false, 2, NULL, 5, 5),
(20, 'https://github.com/lisabrown/threatintel/commit/abc456def789ghi123', 'Lisa Brown', 'lisabrown@securefuture.com', 'abc456def789ghi123', 'https://api.github.com/repos/lisabrown/threatintel/git/commits/abc456def789ghi123', '2026-09-17 21:15:00.000', '2026-09-06 19:00:00.000', false, 2, NULL, 1, 3);


INSERT INTO public.google_search_alerts (query_text, url, page_title, detected_at, last_seen_at, customer_id, notes, state_id, severity_id)
VALUES
('site:pastebin.com confidential site:techsolutions.com', 'https://pastebin.com/abcd1234', 'Confidential Information Leaked', '2026-09-08 10:00:00.000', '2026-09-03 10:00:00.000', 1, NULL, 2, 2), 
('inurl:/secure site:techsolutions.com', 'https://techsolutions.com/secure/login', 'TechSolutions Secure Login', '2026-09-09 12:00:00.000', '2026-09-07 12:00:00.000', 1, NULL, 3, 4), 
('intitle:"Index of /" site:techsolutions.com', 'https://techsolutions.com/files/', 'Index of / - TechSolutions', '2026-09-10 14:00:00.000', '2026-09-07 14:00:00.000', 1, NULL, 1, 3), 
('site:github.com "TechSolutions" confidential', 'https://github.com/user1234/repo1', 'GitHub - TechSolutions Confidential', '2026-09-11 16:00:00.000', '2026-09-07 16:00:00.000', 1, NULL, 3, 5),
('filetype:xls site:techsolutions.com', 'https://techsolutions.com/reports/report.xls', 'TechSolutions Financial Report', '2026-09-12 18:00:00.000', '2026-09-07 18:00:00.000', 1, NULL, 4, 3), 
('site:reddit.com TechSolutions data leak', 'https://reddit.com/r/techsolutions/comments/abcd1234/data_leak/', 'Reddit - TechSolutions Data Leak', '2026-09-13 20:00:00.000', '2026-09-06 20:00:00.000', 1, NULL, 1, 1), 
('intitle:"Dashboard" site:techsolutions.com', 'https://techsolutions.com/dashboard/', 'TechSolutions Dashboard', '2026-09-14 22:00:00.000', '2026-09-07 22:00:00.000', 1, NULL, 3, 4), 
('site:techsolutions.com confidential filetype:pdf', 'https://techsolutions.com/confidential/report.pdf', 'Confidential Report - TechSolutions', '2026-09-15 08:00:00.000', '2026-09-07 08:00:00.000', 1, NULL, 2, 2), 
('inurl:/admin site:techsolutions.com', 'https://techsolutions.com/admin/', 'TechSolutions Admin Panel', '2026-09-16 06:00:00.000', '2026-09-07 06:00:00.000', 1, NULL, 1, 3), 
('site:medium.com "TechSolutions" security issue', 'https://medium.com/@user1234/techsolutions-security-issue-1234abcd', 'Medium - TechSolutions Security Issue', '2026-09-17 04:00:00.000', '2026-09-07 04:00:00.000', 1, NULL, 4, 5),
('site:pastebin.com confidential site:securefuture.com', 'https://pastebin.com/secure1234', 'Confidential Information Leaked - SecureFuture', '2026-09-08 09:00:00.000', '2026-09-03 09:00:00.000', 2, NULL, 2, 3), 
('inurl:/secure site:securefuture.com', 'https://securefuture.com/secure/login', 'SecureFuture Secure Login', '2026-09-09 10:15:00.000', '2026-09-07 10:15:00.000', 2, NULL, 1, 2), 
('intitle:"Index of /" site:securefuture.com', 'https://securefuture.com/files/', 'Index of / - SecureFuture', '2026-09-10 11:30:00.000', '2026-09-07 11:30:00.000', 2, NULL, 4, 4), 
('site:github.com "SecureFuture" confidential', 'https://github.com/user5678/repo2', 'GitHub - SecureFuture Confidential', '2026-09-11 12:45:00.000', '2026-09-07 12:45:00.000', 2, NULL, 3, 5),
('filetype:xls site:securefuture.com', 'https://securefuture.com/reports/data.xls', 'SecureFuture Data Report', '2026-09-12 13:15:00.000', '2026-09-07 13:15:00.000', 2, NULL, 2, 1), 
('site:reddit.com SecureFuture data breach', 'https://reddit.com/r/securefuture/comments/xyz1234/data_breach/', 'Reddit - SecureFuture Data Breach', '2026-09-13 14:45:00.000', '2026-09-06 14:45:00.000', 2, NULL, 1, 2), 
('intitle:"Dashboard" site:securefuture.com', 'https://securefuture.com/dashboard/', 'SecureFuture Dashboard', '2026-09-14 16:00:00.000', '2026-09-07 16:00:00.000', 2, NULL, 4, 4), 
('site:securefuture.com confidential filetype:pdf', 'https://securefuture.com/confidential/report.pdf', 'Confidential Report - SecureFuture', '2026-09-15 17:30:00.000', '2026-09-07 17:30:00.000', 2, NULL, 2, 3), 
('inurl:/admin site:securefuture.com', 'https://securefuture.com/admin/', 'SecureFuture Admin Panel', '2026-09-16 19:00:00.000', '2026-09-07 19:00:00.000', 2, NULL, 3, 2), 
('site:medium.com "SecureFuture" security issue', 'https://medium.com/@user5678/securefuture-security-issue-5678xyz', 'Medium - SecureFuture Security Issue', '2026-09-17 20:15:00.000', '2026-09-07 20:15:00.000', 2, NULL, 4, 5);


INSERT INTO public.google_dork_queries (query_text, customer_id, is_active, added_at, notes)
VALUES
('"TechSolutions confidential" -site:techsolutions.com', 1, true, '2026-09-08 10:00:00.000', NULL),
('"TechSolutions project files" -site:techsolutions.com', 1, false, '2026-09-09 12:00:00.000', NULL),
('"TechSolutions internal documents" -site:techsolutions.com', 1, true, '2026-09-10 14:00:00.000', NULL),
('"TechSolutions sensitive data" -site:techsolutions.com', 1, true, '2026-09-11 16:00:00.000', NULL),
('"TechSolutions budget report" -site:techsolutions.com', 1, true, '2026-09-12 18:00:00.000', NULL),
('"TechSolutions password filetype:txt" -site:techsolutions.com', 1, true, '2026-09-13 20:00:00.000', NULL),
('"TechSolutions site:pastebin.com" -site:techsolutions.com', 1, false, '2026-09-14 22:00:00.000', NULL),
('"TechSolutions login credentials" -site:techsolutions.com', 1, true, '2026-09-15 08:00:00.000', NULL),
('"TechSolutions employee data" -site:techsolutions.com', 1, false, '2026-09-16 06:00:00.000', NULL),
('"TechSolutions project plans" -site:techsolutions.com', 1, true, '2026-09-17 04:00:00.000', NULL),
('"SecureFuture confidential" -site:securefuture.com', 2, true, '2026-09-08 09:30:00.000', NULL),
('"SecureFuture project files" -site:securefuture.com', 2, false, '2026-09-09 10:45:00.000', NULL),
('"SecureFuture internal documents" -site:securefuture.com', 2, true, '2026-09-10 12:15:00.000', NULL),
('"SecureFuture sensitive data" -site:securefuture.com', 2, true, '2026-09-11 13:30:00.000', NULL),
('"SecureFuture budget report" -site:securefuture.com', 2, true, '2026-09-12 14:45:00.000', NULL),
('"SecureFuture password filetype:txt" -site:securefuture.com', 2, true, '2026-09-13 16:00:00.000', NULL),
('"SecureFuture site:pastebin.com" -site:securefuture.com', 2, false, '2026-09-14 17:15:00.000', NULL),
('"SecureFuture login credentials" -site:securefuture.com', 2, true, '2026-09-15 18:30:00.000', NULL),
('"SecureFuture employee data" -site:securefuture.com', 2, false, '2026-09-16 19:45:00.000', NULL),
('"SecureFuture project plans" -site:securefuture.com', 2, true, '2026-09-17 21:00:00.000', NULL);



INSERT INTO public.intelx_leak_alerts (domain_id, leak_name, url, source_bucket, detected_at, customer_id, notes, state_id, severity_id)
VALUES
(1, 'https://techsolhack.com/data-leak/', 'https://intelx.io?did=a1234b5678-c910-11e2-98f6-0800200c9a66', 'web.public.hack', '2026-09-08 14:15:30.123', 1, NULL, 1, 3),
(2, 'https://techdataexpose.net/info/', 'https://intelx.io?did=b2345c6789-d101-21e2-99g7-0900301d9b77', 'web.public.expose', '2026-09-09 10:25:45.456', 1, NULL, 2, 5),
(3, 'https://leaktechinfo.io/docs/', 'https://intelx.io?did=c3456d7890-e212-32e3-00h8-1000402e0c88', 'web.public.leak', '2026-09-10 18:35:22.789', 1, NULL, 3, 2),
(4, 'https://compromise.techinfo.com/files/', 'https://intelx.io?did=d4567e8901-f323-43e4-11i9-1100503f1d99', 'web.public.compromise', '2026-09-11 09:45:55.321', 1, NULL, 4, 4),
(5, 'https://datanews.techsol.com/updates/', 'https://intelx.io?did=e5678f9012-g434-54e5-22j0-1200604g2e10', 'web.public.news', '2026-09-12 16:55:40.654', 1, NULL, 1, 3),
(6, 'https://exposefiles.net/records/', 'https://intelx.io?did=f6789g0123-h545-65e6-33k1-1300705h3f21', 'web.public.exposefiles', '2026-09-13 13:05:10.987', 1, NULL, 2, 1),
(7, 'https://datasecurity.techsol.io/leaks/', 'https://intelx.io?did=g7890h1234-i656-76e7-44l2-1400806i4g32', 'web.public.security', '2026-09-14 19:15:25.210', 1, NULL, 5, 4),
(8, 'https://leakedtechfiles.org/info/', 'https://intelx.io?did=h8901i2345-j767-87e8-55m3-1500907j5h43', 'web.public.leaked', '2026-09-15 11:25:50.543', 1, NULL, 3, 2),
(9, 'https://compromise.techsolutions.io/documents/', 'https://intelx.io?did=i9012j3456-k878-98e9-66n4-1601008k6i54', 'web.public.compromise', '2026-09-16 15:35:15.876', 1, NULL, 4, 5),
(10, 'https://dataleak.techsol.io/records/', 'https://intelx.io?did=j0123k4567-l989-09e0-77o5-1701109l7j65', 'web.public.dataleak', '2026-09-17 20:45:41.209', 1, NULL, 1, 3),
(11, 'https://securefutureleaks.com/data-leak/', 'https://intelx.io?did=a5678b1234-c910-22e3-88f6-0800200c9b77', 'web.public.leaks', '2026-09-08 10:10:10.123', 2, NULL, 2, 4),
(12, 'https://futureinfoleak.net/expose/', 'https://intelx.io?did=b6789c1234-d212-33e4-99g8-0900301c9a88', 'web.public.expose', '2026-09-09 11:20:20.456', 2, NULL, 1, 3),
(13, 'https://datasecurefuture.org/docs/', 'https://intelx.io?did=c7890d1234-e323-44e5-00h9-1000402d9b99', 'web.public.docs', '2026-09-10 12:30:30.789', 2, NULL, 3, 2),
(14, 'https://compromisefuture.net/files/', 'https://intelx.io?did=d8901e1234-f434-55e6-11i0-1100503e9c00', 'web.public.files', '2026-09-11 13:40:40.321', 2, NULL, 4, 5),
(15, 'https://futureupdates.info/news/', 'https://intelx.io?did=e9012f1234-g545-66e7-22j1-1200604f9d11', 'web.public.news', '2026-09-12 14:50:50.654', 2, NULL, 1, 4),
(16, 'https://secureexposefuture.net/records/', 'https://intelx.io?did=f0123g1234-h656-77e8-33k2-1300705g9e22', 'web.public.records', '2026-09-13 15:55:55.987', 2, NULL, 2, 1),
(17, 'https://leakfuturedata.io/security/', 'https://intelx.io?did=g1234h1234-i767-88e9-44l3-1400806h9f33', 'web.public.security', '2026-09-14 16:00:05.210', 2, NULL, 5, 5),
(18, 'https://futuretechleaks.org/info/', 'https://intelx.io?did=h2345i1234-j878-99e0-55m4-1500907i9g44', 'web.public.info', '2026-09-15 17:10:10.543', 2, NULL, 3, 2),
(19, 'https://securefuturecompromise.io/documents/', 'https://intelx.io?did=i3456j1234-k989-00e1-66n5-1601008j9h55', 'web.public.documents', '2026-09-16 18:15:15.876', 2, NULL, 4, 4),
(20, 'https://futuresecureleaks.net/records/', 'https://intelx.io?did=j4567k1234-l090-11e2-77o6-1701109k9i66', 'web.public.records', '2026-09-17 19:20:20.209', 2, NULL, 2, 3);



INSERT INTO public.monitored_ip_addresses (ip_address, added_at, customer_id, is_active, notes)
VALUES
('192.168.1.10', '2026-09-08 14:22:33.450', 1, true, NULL),
('192.168.1.11', '2026-09-09 10:15:22.123', 1, false, NULL),
('192.168.1.12', '2026-09-10 08:45:11.789', 1, true, NULL),
('192.168.1.13', '2026-09-11 16:30:25.456', 1, false, NULL),
('192.168.1.14', '2026-09-12 11:55:33.678', 1, true, NULL),
('192.168.1.15', '2026-09-13 09:05:55.210', 1, true, NULL),
('192.168.1.16', '2026-09-14 14:45:40.654', 1, true, NULL),
('192.168.1.17', '2026-09-15 17:55:10.987', 1, false, NULL),
('192.168.1.18', '2026-09-16 13:35:50.543', 1, true, NULL),
('192.168.1.19', '2026-09-17 19:25:15.876', 1, true, NULL),
('10.0.0.10', '2026-09-08 10:30:45.123', 2, true, NULL),
('10.0.0.11', '2026-09-09 12:15:22.456', 2, false, NULL),
('10.0.0.12', '2026-09-10 09:45:30.789', 2, true, NULL),
('10.0.0.13', '2026-09-11 16:25:15.321', 2, true, NULL),
('10.0.0.14', '2026-09-12 11:50:40.654', 2, false, NULL),
('10.0.0.15', '2026-09-13 08:15:50.987', 2, true, NULL),
('10.0.0.16', '2026-09-14 14:20:35.210', 2, true, NULL),
('10.0.0.17', '2026-09-15 18:55:40.543', 2, false, NULL),
('10.0.0.18', '2026-09-16 13:35:25.876', 2, true, NULL),
('10.0.0.19', '2026-09-17 19:10:10.432', 2, true, NULL);



INSERT INTO public.monitored_keywords (term, customer_id, is_active, added_at, notes)
VALUES
('Machine Learning', 1, true, '2026-09-08 10:15:25.320', NULL),
('Cloud Computing', 1, true, '2026-09-09 12:35:45.110', NULL),
('Cybersecurity', 1, false, '2026-09-10 08:45:30.540', NULL),
('Blockchain Technology', 1, true, '2026-09-11 15:50:20.220', NULL),
('IoT Solutions', 1, true, '2026-09-12 11:22:10.430', NULL),
('Big Data Analytics', 1, false, '2026-09-13 09:40:50.120', NULL),
('Artificial Intelligence', 1, true, '2026-09-14 14:30:40.230', NULL),
('Smart Cities', 1, true, '2026-09-15 17:20:30.340', NULL),
('Digital Transformation', 1, true, '2026-09-16 13:10:20.450', NULL),
('Autonomous Vehicles', 1, false, '2026-09-17 18:55:10.560', NULL),
('Quantum Computing', 2, true, '2026-09-08 10:45:30.320', NULL),
('Edge Computing', 2, true, '2026-09-09 12:20:45.110', NULL),
('Data Privacy', 2, false, '2026-09-10 09:35:30.540', NULL),
('5G Networks', 2, true, '2026-09-11 16:40:20.220', NULL),
('Green IT', 2, true, '2026-09-12 11:50:10.430', NULL),
('Augmented Reality', 2, false, '2026-09-13 08:25:50.120', NULL),
('Natural Language Processing', 2, true, '2026-09-14 14:50:40.230', NULL),
('Digital Twin', 2, true, '2026-09-15 18:10:30.340', NULL),
('Robotic Process Automation', 2, true, '2026-09-16 13:45:20.450', NULL),
('Wearable Technology', 2, false, '2026-09-17 19:20:10.560', NULL);



INSERT INTO public.leaked_secret_alerts (line_start, line_end, column_start, column_end, matched_text, secret_value, file_path, entropy_score, author_name, author_email, committed_at, commit_message, detection_rule, fingerprint_hash, tag_list, commit_hash, github_alert_id, detected_at, rule_description, notes, state_id, severity_id) 
VALUES
(124, 124, 3, 40, 'api_key: abc123-xyz789', 'abc123-xyz789', 'src/config/settings.py', 3.8274671, 'John Doe', 'johndoe@gmail.com', '2026-09-01', 'Initial commit with configuration settings.', 'generic-api-key', 'a1b2c3d4e5f67890:src/config/settings.py:generic-api-key:124', '[]', 'a1b2c3d4e5f67890', '1', '2026-09-08', 'Generic API Key', NULL, 2, 3),
(215, 215, 5, 38, 'db_password: pass1234', 'pass1234', 'config/db_config.yaml', 4.0123456, 'Jane Smith', 'janesmith@gmail.com', '2026-09-01', 'Database configuration update.', 'db-password', 'b2c3d4e5f6a1b8c9:config/db_config.yaml:db-password:215', '[]', 'b2c3d4e5f6a1b8c9', '2', '2026-09-09', 'Database Password', NULL, 3, 4),
(342, 342, 2, 45, 'secret_token: s3cr3t-t0k3n', 's3cr3t-t0k3n', 'app/secrets.py', 3.5647382, 'Alice Johnson', 'alicej@gmail.com', '2026-09-01', 'Added secret token for app authentication.', 'generic-secret', 'c3d4e5f6a1b2c8d9:app/secrets.py:generic-secret:342', '[]', 'c3d4e5f6a1b2c8d9', '3', '2026-09-10', 'Secret Token', NULL, 1, 2),
(478, 478, 1, 50, 'access_key: a1b2c3d4-5678', 'a1b2c3d4-5678', 'config/keys.json', 3.9987654, 'Bob Brown', 'bobbrown@gmail.com', '2026-09-01', 'Updated access keys for API.', 'access-key', 'd4e5f6a1b2c3d9e8:config/keys.json:access-key:478', '[]', 'd4e5f6a1b2c3d9e8', '4', '2026-09-11', 'Access Key', NULL, 4, 5),
(564, 564, 4, 42, 'api_secret: secret-789', 'secret-789', 'lib/security.py', 3.7291827, 'Charlie Green', 'charliegreen@gmail.com', '2026-09-01', 'Added API secret for secure communication.', 'api-secret', 'e5f6a1b2c3d4e8f7:lib/security.py:api-secret:564', '[]', 'e5f6a1b2c3d4e8f7', '5', '2026-09-12', 'API Secret', NULL, 2, 3),
(231, 231, 3, 39, 'jwt_secret: jwt-123-456', 'jwt-123-456', 'src/jwt_config.py', 3.8827643, 'Dave White', 'davewhite@gmail.com', '2026-09-01', 'JWT secret for token generation.', 'jwt-secret', 'f6a1b2c3d4e5f8g7:src/jwt_config.py:jwt-secret:231', '[]', 'f6a1b2c3d4e5f8g7', '6', '2026-09-13', 'JWT Secret', NULL, 3, 4),
(112, 112, 6, 41, 'oauth_key: oauth-abc-def', 'oauth-abc-def', 'oauth/config.py', 3.6172839, 'Eve Black', 'eveblack@gmail.com', '2026-09-02', 'OAuth key for third-party integration.', 'oauth-key', 'g7f8a1b2c3d4e5h6:oauth/config.py:oauth-key:112', '[]', 'g7f8a1b2c3d4e5h6', '7', '2026-09-14', 'OAuth Key', NULL, 1, 2),
(287, 287, 2, 36, 'ssl_key: ssl-key-1234', 'ssl-key-1234', 'ssl/keys.conf', 3.9234567, 'Frank Brown', 'frankbrown@gmail.com', '2026-09-02', 'SSL key for secure connections.', 'ssl-key', 'h6f8a1b2c3d4e5g7:ssl/keys.conf:ssl-key:287', '[]', 'h6f8a1b2c3d4e5g7', '8', '2026-09-15', 'SSL Key', NULL, 2, 3),
(431, 431, 5, 43, 'encryption_key: enc-key-5678', 'enc-key-5678', 'config/encryption.yaml', 3.7543219, 'Grace Wilson', 'gracewilson@gmail.com', '2026-09-02', 'Encryption key for data protection.', 'encryption-key', 'i7f8a1b2c3d4e5h6:config/encryption.yaml:encryption-key:431', '[]', 'i7f8a1b2c3d4e5h6', '9', '2026-09-16', 'Encryption Key', NULL, 3, 4),
(369, 369, 7, 40, 'token_key: token-789-xyz', 'token-789-xyz', 'tokens/config.js', 3.8912765, 'Henry Miller', 'henrymiller@gmail.com', '2026-09-02', 'Token key for user sessions.', 'token-key', 'j8f8a1b2c3d4e5i7:tokens/config.js:token-key:369', '[]', 'j8f8a1b2c3d4e5i7', '10', '2026-09-17', 'Token Key', NULL, 4, 5);


INSERT INTO public.telegram_message_alerts (monitored_keyword_id, channel_id, message_text, sender_identifier, message_sent_at, customer_id, detected_at, notes, state_id, severity_id)
VALUES
(1, 4, 'email: johndoe@techsolutions.com | password: qwerty123', '-1001234567890', '2026-09-03 10:45:30+00:00', 1, '2026-09-08 14:20:16.721', NULL, 2, 3),
(2, 4, 'email: janedoe@techsolutions.com | password: password123', '-1001234567891', '2026-09-03 11:30:50+00:00', 1, '2026-09-09 15:35:25.872', NULL, 3, 4),
(3, 4, 'Potential phishing attempt: "Verify your account at techsolutions.com/login"', '-1001234567892', '2026-09-03 12:00:45+00:00', 1, '2026-09-10 16:10:12.654', NULL, 1, 2),
(4, 4, 'email: alice@techsolutions.com | password: alice456', '-1001234567893', '2026-09-04 13:45:55+00:00', 1, '2026-09-11 17:25:33.256', NULL, 4, 5),
(5, 4, 'TechSolutions database dump: usernames and passwords exposed', '-1001234567894', '2026-09-04 14:30:20+00:00', 1, '2026-09-12 18:00:40.987', NULL, 2, 3),
(6, 4, 'email: bob@techsolutions.com | password: bob789', '-1001234567895', '2026-09-04 15:15:10+00:00', 1, '2026-09-13 19:10:05.321', NULL, 3, 4),
(7, 4, 'Defacement alert: Homepage of TechSolutions altered', '-1001234567896', '2026-09-05 16:00:25+00:00', 1, '2026-09-14 20:20:22.789', NULL, 1, 2),
(8, 4, 'email: charlie@techsolutions.com | password: charlie012', '-1001234567897', '2026-09-05 16:45:35+00:00', 1, '2026-09-15 21:35:55.432', NULL, 4, 5),
(9, 4, 'TechSolutions VPN credentials leaked', '-1001234567898', '2026-09-05 17:30:45+00:00', 1, '2026-09-16 22:45:10.654', NULL, 2, 3),
(10, 4, 'email: daniel@techsolutions.com | password: daniel345', '-1001234567899', '2026-09-06 18:15:55+00:00', 1, '2026-09-17 23:50:16.721', NULL, 3, 4);



INSERT INTO public.twitter_post_alerts (post_text, display_name, account_handle, url, detected_at, query_text, customer_id, notes, state_id, severity_id)
VALUES
('"TechSolutions is facing critical security issues in their new platform release. Immediate action required." - Security Analyst @cybersecguru', 'Cyber Security News', 'cybersecguru', 'https://twitter.com/cybersecguru/status/1632567415400095204', '2026-09-08 14:10:23.104', 'TechSolutions AND security -from:TechSolutions', 1, NULL, 2, 2),
('"Data breach reported at TechSolutions. Sensitive customer information exposed." - Cyber Watchdog @cyber_watch', 'Cyber Watchdog', 'cyber_watch', 'https://twitter.com/cyber_watch/status/1632567425401095204', '2026-09-09 18:20:45.123', 'TechSolutions AND data breach -from:TechSolutions', 1, NULL, 3, 4),
('"TechSolutions servers vulnerable to latest malware attack, experts warn." - IT News @itnewsdaily', 'IT News Daily', 'itnewsdaily', 'https://twitter.com/itnewsdaily/status/1632567435402095204', '2026-09-10 09:30:55.567', 'TechSolutions AND malware -from:TechSolutions', 1, NULL, 1, 3),
('"Multiple vulnerabilities found in TechSolutions software, patch immediately." - Cyber Defender @cyberdefender', 'Cyber Defender', 'cyberdefender', 'https://twitter.com/cyberdefender/status/1632567445403095204', '2026-09-11 11:40:05.789', 'TechSolutions AND vulnerabilities -from:TechSolutions', 1, NULL, 4, 5),
('"Hackers target TechSolutions, stealing confidential information." - InfoSec Alert @infosecalert', 'InfoSec Alert', 'infosecalert', 'https://twitter.com/infosecalert/status/1632567455404095204', '2026-09-12 15:50:15.256', 'TechSolutions AND hackers -from:TechSolutions', 1, NULL, 2, 2),
('"TechSolutions network compromised, causing major disruptions." - Tech Insider @techinsider', 'Tech Insider', 'techinsider', 'https://twitter.com/techinsider/status/1632567465405095204', '2026-09-13 13:00:25.987', 'TechSolutions AND network -from:TechSolutions', 1, NULL, 3, 4),
('"Critical flaw in TechSolutions payment system, urgent fix needed." - Cyber Watch @cyberwatcher', 'Cyber Watcher', 'cyberwatcher', 'https://twitter.com/cyberwatcher/status/1632567475406095204', '2026-09-14 17:10:35.654', 'TechSolutions AND payment -from:TechSolutions', 1, NULL, 1, 3),
('"TechSolutions exposed to phishing attacks, users advised to be cautious." - Security Advisor @secureadvisor', 'Security Advisor', 'secureadvisor', 'https://twitter.com/secureadvisor/status/1632567485407095204', '2026-09-15 14:20:45.321', 'TechSolutions AND phishing -from:TechSolutions', 1, NULL, 4, 5),
('"Ransomware hits TechSolutions, crippling their operations." - Cyber Alerts @cyberalerts', 'Cyber Alerts', 'cyberalerts', 'https://twitter.com/cyberalerts/status/1632567495408095204', '2026-09-16 12:30:55.789', 'TechSolutions AND ransomware -from:TechSolutions', 1, NULL, 2, 2),
('"Unauthorized access detected in TechSolutions database, investigation underway." - Security Monitor @securmonitor', 'Security Monitor', 'securmonitor', 'https://twitter.com/securmonitor/status/1632567505409095204', '2026-09-17 16:40:05.432', 'TechSolutions AND unauthorized access -from:TechSolutions', 1, NULL, 3, 4);


INSERT INTO public.twitter_dork_queries (query_text, customer_id, is_active, added_at, notes)
VALUES
('TechSolutions AND breach -from:techsolutions_inc -from:TechSolOfficial -from:TechSolSupport -from:TechSolutionsUK -from:TechSolGermany -from:TechSolIndia -from:TechSolSpain -from:TechSolLatam -from:TechSolAfrica', 1, true, '2026-09-08 14:11:13.735', NULL),
('TechSolutions AND hack -from:techsolutions_inc -from:TechSolOfficial -from:TechSolSupport -from:TechSolutionsUK -from:TechSolGermany -from:TechSolIndia -from:TechSolSpain -from:TechSolLatam -from:TechSolAfrica', 1, false, '2026-09-09 09:15:13.735', NULL),
('TechSolutions AND "data leak" -from:techsolutions_inc -from:TechSolOfficial -from:TechSolSupport -from:TechSolutionsUK -from:TechSolGermany -from:TechSolIndia -from:TechSolSpain -from:TechSolLatam -from:TechSolAfrica', 1, true, '2026-09-10 21:22:13.735', NULL),
('TechSolutions AND "confidential information" -from:techsolutions_inc -from:TechSolOfficial -from:TechSolSupport -from:TechSolutionsUK -from:TechSolGermany -from:TechSolIndia -from:TechSolSpain -from:TechSolLatam -from:TechSolAfrica', 1, true, '2026-09-11 18:37:13.735', NULL),
('TechSolutions AND "security breach" -from:techsolutions_inc -from:TechSolOfficial -from:TechSolSupport -from:TechSolutionsUK -from:TechSolGermany -from:TechSolIndia -from:TechSolSpain -from:TechSolLatam -from:TechSolAfrica', 1, false, '2026-09-12 10:45:13.735', NULL),
('TechSolutions AND "cyber attack" -from:techsolutions_inc -from:TechSolOfficial -from:TechSolSupport -from:TechSolutionsUK -from:TechSolGermany -from:TechSolIndia -from:TechSolSpain -from:TechSolLatam -from:TechSolAfrica', 1, true, '2026-09-13 12:30:13.735', NULL),
('TechSolutions AND "data breach" -from:techsolutions_inc -from:TechSolOfficial -from:TechSolSupport -from:TechSolutionsUK -from:TechSolGermany -from:TechSolIndia -from:TechSolSpain -from:TechSolLatam -from:TechSolAfrica', 1, true, '2026-09-14 15:50:13.735', NULL),
('TechSolutions AND "security flaw" -from:techsolutions_inc -from:TechSolOfficial -from:TechSolSupport -from:TechSolutionsUK -from:TechSolGermany -from:TechSolIndia -from:TechSolSpain -from:TechSolLatam -from:TechSolAfrica', 1, false, '2026-09-15 08:40:13.735', NULL),
('TechSolutions AND "data exposure" -from:techsolutions_inc -from:TechSolOfficial -from:TechSolSupport -from:TechSolutionsUK -from:TechSolGermany -from:TechSolIndia -from:TechSolSpain -from:TechSolLatam -from:TechSolAfrica', 1, true, '2026-09-16 22:22:13.735', NULL),
('TechSolutions AND "ransomware" -from:techsolutions_inc -from:TechSolOfficial -from:TechSolSupport -from:TechSolutionsUK -from:TechSolGermany -from:TechSolIndia -from:TechSolSpain -from:TechSolLatam -from:TechSolAfrica', 1, true, '2026-09-17 11:11:13.735', NULL),
('SecureFuture AND breach -from:securefuture_inc -from:SecureFutureOfficial -from:SecureFutureSupport', 2, true, '2026-09-08 14:30:13.735', NULL),
('SecureFuture AND hack -from:securefuture_inc -from:SecureFutureOfficial -from:SecureFutureSupport', 2, false, '2026-09-09 09:50:13.735', NULL),
('SecureFuture AND "data leak" -from:securefuture_inc -from:SecureFutureOfficial -from:SecureFutureSupport', 2, true, '2026-09-10 20:20:13.735', NULL),
('SecureFuture AND "confidential information" -from:securefuture_inc -from:SecureFutureOfficial -from:SecureFutureSupport', 2, true, '2026-09-11 19:00:13.735', NULL),
('SecureFuture AND "security breach" -from:securefuture_inc -from:SecureFutureOfficial -from:SecureFutureSupport', 2, false, '2026-09-12 11:15:13.735', NULL),
('SecureFuture AND "cyber attack" -from:securefuture_inc -from:SecureFutureOfficial -from:SecureFutureSupport', 2, true, '2026-09-13 13:45:13.735', NULL),
('SecureFuture AND "data breach" -from:securefuture_inc -from:SecureFutureOfficial -from:SecureFutureSupport', 2, true, '2026-09-14 16:30:13.735', NULL),
('SecureFuture AND "security flaw" -from:securefuture_inc -from:SecureFutureOfficial -from:SecureFutureSupport', 2, false, '2026-09-15 09:20:13.735', NULL),
('SecureFuture AND "data exposure" -from:securefuture_inc -from:SecureFutureOfficial -from:SecureFutureSupport', 2, true, '2026-09-16 21:50:13.735', NULL),
('SecureFuture AND "ransomware" -from:securefuture_inc -from:SecureFutureOfficial -from:SecureFutureSupport', 2, true, '2026-09-17 10:40:13.735', NULL);


INSERT INTO public.typosquatting_alerts (domain_id, lookalike_domain, resolved_ip, detected_at, customer_id, notes, state_id, severity_id)
VALUES
(1, 'techsolutons.com', '198.51.100.225', '2026-09-08 10:20:30.400', 1, NULL, 1, 2), 
(2, 'techsoltions.net', '203.0.113.128', '2026-09-09 14:35:50.123', 1, NULL, 2, 3), 
(3, 'techsloutions.org', '192.0.2.5', '2026-09-10 08:15:45.567', 1, NULL, 3, 4), 
(4, 'techsollutions.co', '203.0.113.27', '2026-09-11 12:00:20.789', 1, NULL, 4, 5), 
(5, 'ttechsolutions.com', '198.51.100.35', '2026-09-12 09:45:33.256', 1, NULL, 1, 1), 
(6, 'tecksolutions.biz', '192.0.2.85', '2026-09-13 11:25:40.987', 1, NULL, 2, 2), 
(7, 'tech-solutons.io', '203.0.113.45', '2026-09-14 16:50:12.654', 1, NULL, 3, 3), 
(8, 'tech-soultions.org', '198.51.100.115', '2026-09-15 14:30:05.321', 1, NULL, 4, 4), 
(9, 'techsoluitons.co', '192.0.2.55', '2026-09-16 13:15:22.789', 1, NULL, 5, 5), 
(10, 'tecsolutions.com', '203.0.113.78', '2026-09-17 17:40:55.432', 1, NULL, 1, 2),
(11, 'securefutuer.com', '203.0.114.125', '2026-09-08 10:45:30.500', 2, NULL, 1, 3), 
(12, 'securfuture.net', '198.51.101.215', '2026-09-09 14:20:15.230', 2, NULL, 2, 4), 
(13, 'secure-futurre.org', '192.0.3.15', '2026-09-10 09:50:10.345', 2, NULL, 3, 5), 
(14, 'secur-future.co', '203.0.115.47', '2026-09-11 12:30:25.600', 2, NULL, 4, 2), 
(15, 'secureffuture.com', '198.51.102.56', '2026-09-12 08:15:20.400', 2, NULL, 1, 1), 
(16, 'securefuture.biz', '192.0.3.85', '2026-09-13 10:40:35.789', 2, NULL, 2, 3), 
(17, 'secure-futre.io', '203.0.116.89', '2026-09-14 15:20:45.200', 2, NULL, 3, 2), 
(18, 'secure-futuure.org', '198.51.103.95', '2026-09-15 14:50:10.150', 2, NULL, 4, 5), 
(19, 'securefuturee.co', '192.0.3.105', '2026-09-16 13:30:55.875', 2, NULL, 5, 4), 
(20, 'securefutureonline.com', '203.0.117.65', '2026-09-17 18:05:40.675', 2, NULL, 1, 2);



INSERT INTO public.certificate_alerts (domain_id, certificate_summary, detected_at, customer_id, notes, state_id, severity_id)
VALUES 
(1, '[9524835931896759054319151040015306696] 2024-06-19 00:00:00 -> 2025-01-10 23:59:59 {CN: willanawasi.pe}', '2026-09-08 00:00:00.000', 1, '', 1, 3), 
(2, '[7524835931896759054319151040015306698] 2024-07-02 00:00:00 -> 2025-01-11 23:59:59 {CN: techsecure.net}', '2026-09-09 00:00:00.000', 1, '', 2, 2), 
(3, '[8524835931896759054319151040015306699] 2024-07-03 00:00:00 -> 2025-01-12 23:59:59 {CN: solutiontech.org}', '2026-09-10 00:00:00.000', 1, '', 3, 4), 
(4, '[9524835931896759054319151040015306700] 2024-07-04 00:00:00 -> 2025-01-13 23:59:59 {CN: technext.io}', '2026-09-11 00:00:00.000', 1, '', 4, 5), 
(5, '[1524835931896759054319151040015306701] 2024-07-05 00:00:00 -> 2025-01-14 23:59:59 {CN: innovationtech.biz}', '2026-09-12 00:00:00.000', 1, '', 1, 2),
(6, '[2524835931896759054319151040015306702] 2024-07-06 00:00:00 -> 2025-01-15 23:59:59 {CN: techinnovators.co}', '2026-09-13 00:00:00.000', 1, '', 2, 3), 
(7, '[3524835931896759054319151040015306703] 2024-07-07 00:00:00 -> 2025-01-16 23:59:59 {CN: techtrends.tech}', '2026-09-14 00:00:00.000', 1, '', 3, 4), 
(8, '[4524835931896759054319151040015306704] 2024-07-08 00:00:00 -> 2025-01-17 23:59:59 {CN: techsavvy.dev}', '2026-09-15 00:00:00.000', 1, '', 4, 5),
(9, '[5524835931896759054319151040015306705] 2024-07-09 00:00:00 -> 2025-01-18 23:59:59 {CN: techpro.solutions}', '2026-09-16 00:00:00.000', 1, '', 1, 1),
(10, '[6524835931896759054319151040015306706] 2024-07-10 00:00:00 -> 2025-01-19 23:59:59 {CN: techhub.services}', '2026-09-17 00:00:00.000', 1, '', 3, 2),
(11, '[5524835931896759054319151040015306707] 2024-06-19 00:00:00 -> 2025-01-10 23:59:59 {CN: securefuture.net}', '2026-09-08 00:00:00.000', 2, '', 1, 3), 
(12, '[6524835931896759054319151040015306708] 2024-07-02 00:00:00 -> 2025-01-11 23:59:59 {CN: securefuture.org}', '2026-09-09 00:00:00.000', 2, '', 2, 2), 
(13, '[7524835931896759054319151040015306709] 2024-07-03 00:00:00 -> 2025-01-12 23:59:59 {CN: securefuture.biz}', '2026-09-10 00:00:00.000', 2, '', 3, 4), 
(14, '[8524835931896759054319151040015306710] 2024-07-04 00:00:00 -> 2025-01-13 23:59:59 {CN: futuresecure.tech}', '2026-09-11 00:00:00.000', 2, '', 4, 5), 
(15, '[9524835931896759054319151040015306711] 2024-07-05 00:00:00 -> 2025-01-14 23:59:59 {CN: innovationfuture.dev}', '2026-09-12 00:00:00.000', 2, '', 1, 2),
(16, '[1524835931896759054319151040015306712] 2024-07-06 00:00:00 -> 2025-01-15 23:59:59 {CN: futureinnovators.co}', '2026-09-13 00:00:00.000', 2, '', 2, 3), 
(17, '[2524835931896759054319151040015306713] 2024-07-07 00:00:00 -> 2025-01-16 23:59:59 {CN: trendsfuture.io}', '2026-09-14 00:00:00.000', 2, '', 3, 4), 
(18, '[3524835931896759054319151040015306714] 2024-07-08 00:00:00 -> 2025-01-17 23:59:59 {CN: futuresecure.dev}', '2026-09-15 00:00:00.000', 2, '', 4, 5),
(19, '[4524835931896759054319151040015306715] 2024-07-09 00:00:00 -> 2025-01-18 23:59:59 {CN: securefuture.pro}', '2026-09-16 00:00:00.000', 2, '', 1, 1),
(20, '[5524835931896759054319151040015306716] 2024-07-10 00:00:00 -> 2025-01-19 23:59:59 {CN: hubfuture.services}', '2026-09-17 00:00:00.000', 2, '', 3, 2);




INSERT INTO public.defacement_alerts (domain_id, content_md5, content_sha256, detected_at, customer_id, notes, state_id, severity_id)
VALUES 
(1, decode('5064623837643162333366316433346563363230616333633238346137663837','hex'), decode('74653635633938626137373361366434653735363031323064396536636561663261623733396433316239386630393933373439373338356537633039323138','hex'), '2026-09-08 12:25:32.655', 1, NULL, 1, 3), 
(2, decode('4063623837643162333366316433346563363230616333633238346137663837','hex'), decode('64653635633938626137373361366434653735363031323064396536636561663261623733396433316239386630393933373439373338356537633039323138','hex'), '2026-09-09 13:25:32.655', 1, NULL, 2, 4), 
(3, decode('3063623837643162333366316433346563363230616333633238346137663838','hex'), decode('64653635633938626137373361366434653735363031323064396536636561663261623733396433316239386630393933373439373338356537633039323139','hex'), '2026-09-10 14:25:32.655', 1, NULL, 3, 2), 
(4, decode('2063623837643162333366316433346563363230616333633238346137663839','hex'), decode('64653635633938626137373361366434653735363031323064396536636561663261623733396433316239386630393933373439373338356537633039323130','hex'), '2026-09-11 15:25:32.655', 1, NULL, 4, 5), 
(5, decode('1063623837643162333366316433346563363230616333633238346137663840','hex'), decode('64653635633938626137373361366434653735363031323064396536636561663261623733396433316239386630393933373439373338356537633039323131','hex'), '2026-09-12 16:25:32.655', 1, NULL, 1, 1), 
(6, decode('9063623837643162333366316433346563363230616333633238346137663841','hex'), decode('64653635633938626137373361366434653735363031323064396536636561663261623733396433316239386630393933373439373338356537633039323132','hex'), '2026-09-13 17:25:32.655', 1, NULL, 2, 3), 
(7, decode('8063623837643162333366316433346563363230616333633238346137663842','hex'), decode('64653635633938626137373361366434653735363031323064396536636561663261623733396433316239386630393933373439373338356537633039323133','hex'), '2026-09-14 18:25:32.655', 1, NULL, 3, 4), 
(8, decode('7063623837643162333366316433346563363230616333633238346137663843','hex'), decode('64653635633938626137373361366434653735363031323064396536636561663261623733396433316239386630393933373439373338356537633039323134','hex'), '2026-09-15 19:25:32.655', 1, NULL, 4, 5), 
(9, decode('6063623837643162333366316433346563363230616333633238346137663844','hex'), decode('64653635633938626137373361366434653735363031323064396536636561663261623733396433316239386630393933373439373338356537633039323135','hex'), '2026-09-16 20:25:32.655', 1, NULL, 1, 2), 
(10, decode('5063623837643162333366316433346563363230616333633238346137663845','hex'), decode('64653635633938626137373361366434653735363031323064396536636561663261623733396433316239386630393933373439373338356537633039323136','hex'), '2026-09-17 21:25:32.655', 1, NULL, 3, 3),
(11, decode('4062633837643162333366316433346563363230616333633238346137663837','hex'), decode('73643635633938626137373361366434653735363031323064396536636561663261623733396433316239386630393933373439373338356537633039323138','hex'), '2026-09-08 12:45:32.655', 2, NULL, 1, 2), 
(12, decode('3062633837643162333366316433346563363230616333633238346137663837','hex'), decode('64643635633938626137373361366434653735363031323064396536636561663261623733396433316239386630393933373439373338356537633039323139','hex'), '2026-09-09 13:55:32.655', 2, NULL, 2, 4), 
(13, decode('2062633837643162333366316433346563363230616333633238346137663838','hex'), decode('64643635633938626137373361366434653735363031323064396536636561663261623733396433316239386630393933373439373338356537633039323130','hex'), '2026-09-10 14:35:32.655', 2, NULL, 3, 3), 
(14, decode('1062633837643162333366316433346563363230616333633238346137663839','hex'), decode('64643635633938626137373361366434653735363031323064396536636561663261623733396433316239386630393933373439373338356537633039323131','hex'), '2026-09-11 15:25:32.655', 2, NULL, 4, 5), 
(15, decode('9062633837643162333366316433346563363230616333633238346137663840','hex'), decode('64643635633938626137373361366434653735363031323064396536636561663261623733396433316239386630393933373439373338356537633039323132','hex'), '2026-09-12 16:45:32.655', 2, NULL, 1, 1), 
(16, decode('8062633837643162333366316433346563363230616333633238346137663841','hex'), decode('64643635633938626137373361366434653735363031323064396536636561663261623733396433316239386630393933373439373338356537633039323133','hex'), '2026-09-13 17:25:32.655', 2, NULL, 2, 3), 
(17, decode('7062633837643162333366316433346563363230616333633238346137663842','hex'), decode('64643635633938626137373361366434653735363031323064396536636561663261623733396433316239386630393933373439373338356537633039323134','hex'), '2026-09-14 18:15:32.655', 2, NULL, 3, 4), 
(18, decode('6062633837643162333366316433346563363230616333633238346137663843','hex'), decode('64643635633938626137373361366434653735363031323064396536636561663261623733396433316239386630393933373439373338356537633039323135','hex'), '2026-09-15 19:45:32.655', 2, NULL, 4, 5), 
(19, decode('5062633837643162333366316433346563363230616333633238346137663844','hex'), decode('64643635633938626137373361366434653735363031323064396536636561663261623733396433316239386630393933373439373338356537633039323136','hex'), '2026-09-16 20:35:32.655', 2, NULL, 1, 2), 
(20, decode('4062633837643162333366316433346563363230616333633238346137663845','hex'), decode('64643635633938626137373361366434653735363031323064396536636561663261623733396433316239386630393933373439373338356537633039323137','hex'), '2026-09-17 21:15:32.655', 2, NULL, 3, 3);



INSERT INTO public.gitlab_project_alerts (monitored_keyword_id, project_name, author_name, project_description, url, project_created_at, detected_at, customer_id, notes, state_id, severity_id)
VALUES 
(1, 'Secure-Notes-App', 'Alice Murray', 'A secure note-taking app project', 'https://gitlab.com/alicemurray/Secure-Notes-App.git', '2026-09-07T10:00:00.000Z', '2026-09-08 11:22:33.000', 1, NULL, 1, 3), 
(2, 'Data-Analysis-Toolkit', 'Bob Peterson', 'Tools for data analysis and visualization', 'https://gitlab.com/bobpeterson/Data-Analysis-Toolkit.git', '2026-09-07T12:00:00.000Z', '2026-09-09 12:34:45.000', 1, NULL, 2, 4), 
(3, 'Network-Security-Suite', 'Carol White', 'Suite of tools for network security', 'https://gitlab.com/carolwhite/Network-Security-Suite.git', '2026-09-07T14:00:00.000Z', '2026-09-10 13:45:56.000', 1, NULL, 3, 2), 
(4, 'Web-App-Firewall', 'David Brown', 'A project for building a web application firewall', 'https://gitlab.com/davidbrown/Web-App-Firewall.git', '2026-09-07T16:00:00.000Z', '2026-09-11 14:56:07.000', 1, NULL, 4, 5),
(5, 'Phishing-Detection-Tool', 'Evelyn Green', 'Tool for detecting phishing attacks', 'https://gitlab.com/evelyngreen/Phishing-Detection-Tool.git', '2026-09-06T18:00:00.000Z', '2026-09-12 15:34:18.000', 1, NULL, 1, 1), 
(6, 'Malware-Analysis-Platform', 'Frank Harris', 'Platform for analyzing malware samples', 'https://gitlab.com/frankharris/Malware-Analysis-Platform.git', '2026-09-06T20:00:00.000Z', '2026-09-13 16:45:29.000', 1, NULL, 2, 3), 
(7, 'IoT-Security-Framework', 'Grace Lee', 'Security framework for IoT devices', 'https://gitlab.com/gracelee/IoT-Security-Framework.git', '2026-09-06T22:00:00.000Z', '2026-09-14 17:56:40.000', 1, NULL, 3, 4), 
(8, 'Crypto-Analysis-Tool', 'Henry Clark', 'Tool for analyzing cryptographic algorithms', 'https://gitlab.com/henryclark/Crypto-Analysis-Tool.git', '2026-09-06T23:00:00.000Z', '2026-09-15 18:07:51.000', 1, NULL, 4, 5), 
(9, 'Incident-Response-Manager', 'Irene Adams', 'Manager for handling security incidents', 'https://gitlab.com/ireneadams/Incident-Response-Manager.git', '2026-09-06T08:00:00.000Z', '2026-09-16 19:18:02.000', 1, NULL, 1, 2), 
(10, 'Threat-Intelligence-Platform', 'Jack Wilson', 'Platform for gathering and analyzing threat intelligence', 'https://gitlab.com/jackwilson/Threat-Intelligence-Platform.git', '2026-09-06T06:00:00.000Z', '2026-09-17 20:29:13.000', 1, NULL, 3, 3),
(11, 'Advanced-Encryption-Manager', 'Sophia Baker', 'Manager for handling advanced encryption techniques', 'https://gitlab.com/sophiabaker/Advanced-Encryption-Manager.git', '2026-09-05T10:00:00.000Z', '2026-09-08 10:22:33.000', 2, NULL, 1, 2), 
(12, 'Secure-Cloud-Platform', 'Liam Johnson', 'Platform for managing secure cloud environments', 'https://gitlab.com/liamjohnson/Secure-Cloud-Platform.git', '2026-09-05T12:00:00.000Z', '2026-09-09 11:34:45.000', 2, NULL, 2, 4), 
(13, 'Vulnerability-Scanner', 'Emily Roberts', 'Tool for scanning and identifying vulnerabilities', 'https://gitlab.com/emilyroberts/Vulnerability-Scanner.git', '2026-09-05T14:00:00.000Z', '2026-09-10 12:45:56.000', 2, NULL, 3, 3), 
(14, 'Secure-API-Gateway', 'James Lee', 'Project for creating a secure API gateway', 'https://gitlab.com/jameslee/Secure-API-Gateway.git', '2026-09-05T16:00:00.000Z', '2026-09-11 13:56:07.000', 2, NULL, 4, 5),
(15, 'Phishing-Awareness-Program', 'Olivia Davis', 'Tool to raise awareness about phishing attacks', 'https://gitlab.com/oliviadavis/Phishing-Awareness-Program.git', '2026-09-05T18:00:00.000Z', '2026-09-12 14:34:18.000', 2, NULL, 1, 1), 
(16, 'Malware-Detection-System', 'Mason Garcia', 'System for detecting and analyzing malware', 'https://gitlab.com/masongarcia/Malware-Detection-System.git', '2026-09-05T20:00:00.000Z', '2026-09-13 15:45:29.000', 2, NULL, 2, 3), 
(17, 'IoT-Monitoring-Suite', 'Ava Martinez', 'Suite for monitoring IoT devices', 'https://gitlab.com/avamartinez/IoT-Monitoring-Suite.git', '2026-09-04T22:00:00.000Z', '2026-09-14 16:56:40.000', 2, NULL, 3, 4), 
(18, 'Encryption-Algorithm-Tool', 'Benjamin Lopez', 'Tool for analyzing and implementing encryption algorithms', 'https://gitlab.com/benjaminlopez/Encryption-Algorithm-Tool.git', '2026-09-04T23:00:00.000Z', '2026-09-15 17:07:51.000', 2, NULL, 4, 5), 
(19, 'Incident-Tracking-System', 'Charlotte Wilson', 'System for tracking and managing security incidents', 'https://gitlab.com/charlottewilson/Incident-Tracking-System.git', '2026-09-04T08:00:00.000Z', '2026-09-16 18:18:02.000', 2, NULL, 1, 2), 
(20, 'Cyber-Threat-Analysis', 'Lucas Brown', 'Platform for analyzing and mitigating cyber threats', 'https://gitlab.com/lucasbrown/Cyber-Threat-Analysis.git', '2026-09-04T06:00:00.000Z', '2026-09-17 19:29:13.000', 2, NULL, 3, 3);



INSERT INTO public.shodan_legacy_alerts (id, domain_id, ip_address, asn_number, vulnerability_id, country_name, detected_at, customer_id, notes, state_id, severity_id)
VALUES
(1, 1, '52.142.110.223', 'AS8075', 'CVE-2020-10188', 'Germany', '2026-09-08 11:20:10.320', 1, NULL, 1, 2),
(2, 2, '13.65.55.11', 'AS8075', 'CVE-2018-10933', 'France', '2026-09-09 09:15:30.210', 1, NULL, 2, 3), 
(3, 3, '40.112.72.201', 'AS8075', 'CVE-2017-0143', 'Spain', '2026-09-10 14:25:45.110', 1, NULL, 3, 4), 
(4, 4, '191.237.244.98', 'AS8075', 'CVE-2019-0708', 'United Kingdom', '2026-09-11 16:45:50.220', 1, NULL, 4, 1), 
(5, 5, '168.63.28.99', 'AS8075', 'CVE-2021-3156', 'Italy', '2026-09-12 18:55:35.430', 1, NULL, 1, 3), 
(6, 6, '23.100.15.180', 'AS8075', 'CVE-2020-1350', 'Netherlands', '2026-09-13 20:05:25.120', 1, NULL, 2, 5), 
(7, 7, '104.46.101.106', 'AS8075', 'CVE-2017-5638', 'Belgium', '2026-09-14 21:15:40.230', 1, NULL, 3, 2), 
(8, 8, '52.174.34.92', 'AS8075', 'CVE-2021-34473', 'Ireland', '2026-09-15 22:25:55.340', 1, NULL, 4, 3), 
(9, 9, '191.232.139.51', 'AS8075', 'CVE-2019-11510', 'Sweden', '2026-09-16 23:35:40.450', 1, NULL, 1, 4),
(10, 10, '40.89.167.88', 'AS8075', 'CVE-2022-22965', 'Switzerland', '2026-09-17 00:45:55.560', 1, NULL, 2, 1); 




INSERT INTO public.shodan_host_alerts (domain_names, ip_address, query_text, asn_number, country_name, hostname_list, organization_name, customer_id, detected_at, cpe_list, notes, state_id, severity_id) 
VALUES
('[techsolutions.com, amazonaws.com]', '52.123.45.67', 'techsolutions OR securedata OR mysite OR info -country:US,IN,AU,UK -org:Google', 'AS45678', 'United States', '[''techsolutions.com'', ''ec2-52-123-45-67.us-west-1.compute.amazonaws.com'']', 'Amazon Web Services', 1, '2026-09-08 10:30:21.123', '[''cpe:/a:openssl:openssl'']', NULL, 1, 2), 
('[blacklist.com, cloudflare.com]', '104.16.23.45', 'blacklist OR techsecure OR datahub OR sysadmin -country:CA,DE,JP -org:Microsoft', 'AS13335', 'Canada', '[''blacklist.com'', ''104.16.23.45.cloudflare.com'']', 'Cloudflare, Inc.', 1, '2026-09-09 14:45:30.567', '[''cpe:/a:apache:http_server'']', NULL, 2, 3), 
('[myapp.com, digitalocean.com]', '159.89.38.90', 'myapp OR appsecure OR techdomain OR admin -country:FR,IT,ES -org:Amazon', 'AS14061', 'France', '[''myapp.com'', ''159.89.38.90.digitalocean.com'']', 'DigitalOcean, LLC', 1, '2026-09-10 08:12:45.234', '[''cpe:/a:nginx:nginx'']', NULL, 3, 4), 
('[securedata.com, linode.com]', '173.255.255.254', 'securedata OR techserver OR infosec OR site -country:BR,AR,MX -org:Apple', 'AS63949', 'Brazil', '[''securedata.com'', ''173-255-255-254.ip.linodeusercontent.com'']', 'Linode, LLC', 1, '2026-09-11 16:22:11.890', '[''cpe:/a:php:php'']', NULL, 4, 1), 
('[infotech.com, vultr.com]', '207.246.67.123', 'infotech OR datasecure OR network OR admin -country:SG,MY,ID -org:IBM', 'AS20473', 'Singapore', '[''infotech.com'', ''207.246.67.123.vultr.com'']', 'Choopa, LLC', 1, '2026-09-12 12:33:44.765', '[''cpe:/a:nodejs:node.js'']', NULL, 1, 3), 
('[datasystems.com, ovh.com]', '51.91.60.123', 'datasystems OR techsecure OR netsafe OR sysadmin -country:IT,NL,SE -org:Oracle', 'AS16276', 'Italy', '[''datasystems.com'', ''51.91.60.123.ovh.net'']', 'OVH SAS', 1, '2026-09-13 19:28:56.321', '[''cpe:/a:python:python'']', NULL, 2, 5), 
('[cloudsecure.com, azure.com]', '52.136.45.67', 'cloudsecure OR techcloud OR infotech OR admin -country:KR,TW,CN -org:Google', 'AS8075', 'South Korea', '[''cloudsecure.com'', ''52.136.45.67.azure.com'']', 'Microsoft Azure', 1, '2026-09-14 09:11:32.654', '[''cpe:/a:perl:perl'']', NULL, 3, 2), 
('[cyberdefense.com, heroku.com]', '23.21.159.123', 'cyberdefense OR techdefense OR dataprotect OR site -country:IN,PK,BD -org:Amazon', 'AS14618', 'India', '[''cyberdefense.com'', ''23.21.159.123.compute-1.amazonaws.com'']', 'Heroku, Inc.', 1, '2026-09-15 13:40:45.789', '[''cpe:/a:ruby:ruby'']', NULL, 4, 3), 
('[netsolutions.com, gcp.com]', '35.224.123.45', 'netsolutions OR technetwork OR securesite OR admin -country:AU,NZ,SG -org:Microsoft', 'AS15169', 'Australia', '[''netsolutions.com'', ''35.224.123.45.gcp.com'']', 'Google Cloud Platform', 1, '2026-09-16 11:20:33.987', '[''cpe:/a:mysql:mysql'']', NULL, 1, 4), 
('[techhub.com, digitalocean.com]', '159.203.45.67', 'techhub OR securehub OR datacenter OR sysadmin -country:RU,UA,PL -org:Amazon', 'AS14061', 'Russia', '[''techhub.com'', ''159.203.45.67.digitalocean.com'']', 'DigitalOcean, LLC', 1, '2026-09-17 07:55:29.432', '[''cpe:/a:java:openjdk'']', NULL, 2, 1),
('[securefuture.com, amazonaws.com]', '34.123.67.89', 'securefuture OR datasecure OR infowatch OR site -country:US,UK,CA,DE -org:Google', 'AS56789', 'United States', '[''securefuture.com'', ''ec2-34-123-67-89.us-west-2.compute.amazonaws.com'']', 'Amazon Web Services', 2, '2026-09-08 10:45:31.123', '[''cpe:/a:openssl:openssl'']', NULL, 1, 2), 
('[defensehub.com, cloudflare.com]', '104.21.23.67', 'defensehub OR techsecure OR datasafe OR network -country:JP,FR,AU,IT -org:Microsoft', 'AS12345', 'Canada', '[''defensehub.com'', ''104.21.23.67.cloudflare.com'']', 'Cloudflare, Inc.', 2, '2026-09-09 15:30:12.456', '[''cpe:/a:apache:http_server'']', NULL, 2, 4), 
('[cybersafe.com, digitalocean.com]', '198.51.100.45', 'cybersafe OR protectzone OR datacenter OR admin -country:IN,BR,SG,MY -org:Amazon', 'AS67890', 'Singapore', '[''cybersafe.com'', ''198.51.100.45.digitalocean.com'']', 'DigitalOcean, LLC', 2, '2026-09-10 09:20:22.789', '[''cpe:/a:nginx:nginx'']', NULL, 3, 3), 
('[securelink.com, linode.com]', '192.0.2.123', 'securelink OR protectzone OR infosec OR site -country:RU,UA,PL,ES -org:Oracle', 'AS33445', 'Russia', '[''securelink.com'', ''192.0.2.123.ip.linodeusercontent.com'']', 'Linode, LLC', 2, '2026-09-11 17:45:33.456', '[''cpe:/a:php:php'']', NULL, 4, 5), 
('[infoprotect.com, azure.com]', '52.67.89.123', 'infoprotect OR networkguard OR datasafe OR tech -country:KR,ID,PH,TH -org:Microsoft', 'AS98765', 'South Korea', '[''infoprotect.com'', ''52.67.89.123.azure.com'']', 'Microsoft Azure', 2, '2026-09-12 13:15:44.765', '[''cpe:/a:nodejs:node.js'']', NULL, 1, 3), 
('[datahubsecure.com, ovh.com]', '51.91.78.123', 'datahubsecure OR dataprotect OR infoshield OR admin -country:NL,SE,FI,DK -org:Oracle', 'AS12367', 'Italy', '[''datahubsecure.com'', ''51.91.78.123.ovh.net'']', 'OVH SAS', 2, '2026-09-13 18:30:55.432', '[''cpe:/a:python:python'']', NULL, 2, 4), 
('[cyberfort.com, gcp.com]', '35.224.78.45', 'cyberfort OR netsecure OR techcloud OR admin -country:CN,JP,KR,TH -org:Google', 'AS89123', 'China', '[''cyberfort.com'', ''35.224.78.45.gcp.com'']', 'Google Cloud Platform', 2, '2026-09-14 11:11:33.876', '[''cpe:/a:perl:perl'']', NULL, 3, 2), 
('[shieldtech.com, heroku.com]', '23.32.145.123', 'shieldtech OR techshield OR cyberhub OR network -country:AU,NZ,MY,PH -org:Amazon', 'AS45632', 'Australia', '[''shieldtech.com'', ''23.32.145.123.compute-1.amazonaws.com'']', 'Heroku, Inc.', 2, '2026-09-15 14:35:22.567', '[''cpe:/a:ruby:ruby'']', NULL, 4, 5), 
('[securewatch.com, linode.com]', '203.0.113.45', 'securewatch OR datafort OR netguard OR techzone -country:DE,IT,UK,ES -org:Microsoft', 'AS65432', 'Germany', '[''securewatch.com'', ''203.0.113.45.linode.com'']', 'Linode, LLC', 2, '2026-09-16 12:20:18.998', '[''cpe:/a:mysql:mysql'']', NULL, 1, 1), 
('[techguardian.com, vultr.com]', '207.246.56.78', 'techguardian OR datasafe OR cyberfort OR network -country:US,CA,MX,BR -org:Google', 'AS20473', 'United States', '[''techguardian.com'', ''207.246.56.78.vultr.com'']', 'Vultr, LLC', 2, '2026-09-17 08:15:29.123', '[''cpe:/a:java:openjdk'']', NULL, 2, 2);



INSERT INTO public.shodan_dork_queries (query_text, customer_id, is_active, added_at, notes)
VALUES
('TechSolutions OR secureapp OR datasafe OR fintechpro OR mediashield OR healthsecure OR eduportal OR financeguard OR retailwatch OR travelprotector -country:SG,HK,TW,JP,CN,US,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW (analysis OR monitor OR alert OR defense) -country:HK,TW,JP,CN,US,SG,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW', 1, true, '2026-09-08 08:30:25.040', NULL),
('TechSolutions OR cybersecure OR infoguard OR datashield OR appdefender OR protectzone OR itshield OR networkguard OR securetech OR privacymaster -country:SG,HK,TW,JP,CN,US,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW (monitoring OR security OR firewall OR intrusion) -country:HK,TW,JP,CN,US,SG,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW', 1, false, '2026-09-09 11:42:30.040', NULL),
('TechSolutions OR safezone OR cyberwatch OR infosafe OR appsecure OR databunker OR cyberfort OR netshield OR securelink OR cyberguardian -country:SG,HK,TW,JP,CN,US,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW (scan OR audit OR secure OR alert) -country:HK,TW,JP,CN,US,SG,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW', 1, true, '2026-09-10 14:56:30.040', NULL),
('TechSolutions OR securedata OR protectapp OR netdefender OR techshield OR cybersafe OR infosafe OR dataprotect OR appguard OR securezone -country:SG,HK,TW,JP,CN,US,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW (protection OR alert OR defense OR surveillance) -country:HK,TW,JP,CN,US,SG,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW', 1, false, '2026-09-11 10:12:30.040', NULL),
('TechSolutions OR dataguard OR netprotector OR appsecure OR techfortress OR cybermonitor OR infoshield OR securedata OR networksafe OR techguardian -country:SG,HK,TW,JP,CN,US,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW (safety OR security OR protection OR alert) -country:HK,TW,JP,CN,US,SG,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW', 1, true, '2026-09-12 09:18:30.040', NULL),
('TechSolutions OR infosecure OR datashield OR techdefender OR netguard OR secureapp OR cybershield OR protectdata OR securetech OR appdefender -country:SG,HK,TW,JP,CN,US,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW (defense OR protection OR surveillance OR audit) -country:HK,TW,JP,CN,US,SG,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW', 1, false, '2026-09-13 13:24:30.040', NULL),
('TechSolutions OR datafort OR appguard OR techwatch OR netsecure OR protecttech OR cyberguard OR infosecure OR datasafe OR secureapp -country:SG,HK,TW,JP,CN,US,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW (alert OR security OR monitoring OR defense) -country:HK,TW,JP,CN,US,SG,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW', 1, true, '2026-09-14 15:42:30.040', NULL),
('TechSolutions OR appsecure OR netshield OR dataguard OR techprotect OR cybersecure OR infoshield OR securetech OR datawatch OR appdefender -country:SG,HK,TW,JP,CN,US,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW (audit OR alert OR monitoring OR protection) -country:HK,TW,JP,CN,US,SG,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW', 1, true, '2026-09-15 07:36:30.040', NULL),
('TechSolutions OR techshield OR securedata OR netguard OR appfortress OR cyberwatch OR infosecure OR datashield OR protecttech OR secureapp -country:SG,HK,TW,JP,CN,US,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW (defense OR safety OR audit OR alert) -country:HK,TW,JP,CN,US,SG,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW', 1, true, '2026-09-16 11:48:30.040', NULL),
('TechSolutions OR securefort OR dataguard OR netdefender OR techsecure OR cyberprotector OR infowatch OR securetech OR datasafe OR appshield -country:SG,HK,TW,JP,CN,US,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW (surveillance OR protection OR monitoring OR defense) -country:HK,TW,JP,CN,US,SG,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW', 1, true, '2026-09-17 08:52:30.040', NULL),
('SecureFuture OR safeguard OR datashield OR fintechguard OR mediaprotect OR healthtech OR edusafe OR financewatch OR retailshield OR travelsecure -country:SG,HK,TW,JP,CN,US,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW (monitoring OR alert OR analysis OR firewall) -country:HK,TW,JP,CN,US,SG,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW', 2, true, '2026-09-08 09:00:25.040', NULL),
('SecureFuture OR netsecure OR infowatch OR cyberdefend OR protectzone OR appguard OR datasafe OR securityhub OR privateshield OR safeguard -country:SG,HK,TW,JP,CN,US,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW (analysis OR security OR intrusion OR defense) -country:HK,TW,JP,CN,US,SG,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW', 2, false, '2026-09-09 12:15:30.040', NULL),
('SecureFuture OR databunker OR cyberfort OR infosafe OR netshield OR protectdata OR secureapp OR datafort OR safetyzone OR watchguard -country:SG,HK,TW,JP,CN,US,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW (alert OR secure OR monitoring OR firewall) -country:HK,TW,JP,CN,US,SG,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW', 2, true, '2026-09-10 14:45:30.040', NULL),
('SecureFuture OR protecttech OR netguard OR datahub OR appshield OR securewatch OR techsecure OR privatesafe OR securedata OR shieldfort -country:SG,HK,TW,JP,CN,US,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW (defense OR alert OR analysis OR protection) -country:HK,TW,JP,CN,US,SG,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW', 2, false, '2026-09-11 10:22:30.040', NULL),
('SecureFuture OR safetyhub OR netprotector OR appsecure OR techsafety OR cyberguardian OR securezone OR infoshield OR datasecure OR defensewatch -country:SG,HK,TW,JP,CN,US,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW (surveillance OR monitoring OR protection OR audit) -country:HK,TW,JP,CN,US,SG,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW', 2, true, '2026-09-12 11:48:30.040', NULL),
('SecureFuture OR protectzone OR techshield OR dataguard OR networkfort OR securefort OR datasafe OR apphub OR safehaven OR infozone -country:SG,HK,TW,JP,CN,US,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW (alert OR protection OR firewall OR analysis) -country:HK,TW,JP,CN,US,SG,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW', 2, false, '2026-09-13 13:15:30.040', NULL),
('SecureFuture OR datahub OR protectfort OR secureapp OR netzone OR cybersecure OR safespace OR infohub OR dataguard OR shieldsecure -country:SG,HK,TW,JP,CN,US,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW (defense OR monitoring OR intrusion OR safety) -country:HK,TW,JP,CN,US,SG,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW', 2, true, '2026-09-14 16:35:30.040', NULL),
('SecureFuture OR netguard OR datafort OR protectzone OR safetynet OR cyberhub OR shieldtech OR infosafe OR techguard OR datasafe -country:SG,HK,TW,JP,CN,US,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW (audit OR protection OR secure OR firewall) -country:HK,TW,JP,CN,US,SG,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW', 2, true, '2026-09-15 09:48:30.040', NULL),
('SecureFuture OR appshield OR protecthub OR datasafe OR cyberwatch OR infozone OR shieldfort OR securefort OR protectzone OR netguard -country:SG,HK,TW,JP,CN,US,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW (surveillance OR intrusion OR alert OR defense) -country:HK,TW,JP,CN,US,SG,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW', 2, false, '2026-09-16 11:22:30.040', NULL),
('SecureFuture OR safeguard OR datasafe OR protecttech OR appsecure OR netprotector OR shieldhub OR infowatch OR securedata OR fortifytech -country:SG,HK,TW,JP,CN,US,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW (security OR defense OR monitoring OR audit) -country:HK,TW,JP,CN,US,SG,IN,NZ,CA,TH,AU,ID,KR,BD,CY,MR,VN,MY,PH,ZA,IL,IR,MK,TR,IQ,AE,BY,KE,KH,KZ,LB,MA,MW,OM,RE,SA,TN,ZW', 2, true, '2026-09-17 10:52:30.040', NULL);



INSERT INTO public.shodan_port_alerts (host_alert_id, port_number, detected_at, notes, state_id, severity_id) 
VALUES
(1, 80, '2026-09-08 14:15:11.378', NULL, 1, 4),
(2, 22, '2026-09-09 18:20:11.378', NULL, 2, 3),
(3, 8080, '2026-09-10 11:25:11.378', NULL, 3, 2),
(4, 3306, '2026-09-11 15:30:11.378', NULL, 1, 5),
(5, 25, '2026-09-12 09:35:11.378', NULL, 4, 4),
(6, 21, '2026-09-13 16:40:11.378', NULL, 2, 3),
(7, 23, '2026-09-14 13:45:11.378', NULL, 3, 1),
(8, 3389, '2026-09-15 10:50:11.378', NULL, 1, 4),
(9, 110, '2026-09-16 19:55:11.378', NULL, 5, 2),
(10, 143, '2026-09-17 08:00:11.378', NULL, 2, 5),
(11, 443, '2026-09-08 12:15:11.378', NULL, 3, 4),
(12, 22, '2026-09-09 14:20:11.378', NULL, 1, 3),
(13, 8081, '2026-09-10 16:25:11.378', NULL, 2, 2),
(14, 5432, '2026-09-11 18:30:11.378', NULL, 4, 5),
(15, 1433, '2026-09-12 09:35:11.378', NULL, 3, 2),
(16, 3389, '2026-09-13 11:40:11.378', NULL, 5, 4),
(17, 389, '2026-09-14 13:45:11.378', NULL, 1, 3),
(18, 110, '2026-09-15 15:50:11.378', NULL, 4, 2),
(19, 25, '2026-09-16 17:55:11.378', NULL, 2, 4),
(20, 23, '2026-09-17 19:00:11.378', NULL, 3, 3);




INSERT INTO public.shodan_vulnerability_alerts (host_alert_id, vulnerability_id, detected_at, notes, state_id, severity_id)
VALUES
(1, 'CVE-2021-44228', '2026-09-08 08:15:30.123', NULL, 1, 1),
(2, 'CVE-2020-1472', '2026-09-09 12:45:50.567', NULL, 2, 2),
(3, 'CVE-2018-11776', '2026-09-10 14:22:10.234', NULL, 3, 3),
(4, 'CVE-2022-22965', '2026-09-11 16:30:45.890', NULL, 1, 4),
(5, 'CVE-2017-5638', '2026-09-12 09:40:25.765', NULL, 2, 2),
(6, 'CVE-2021-34527', '2026-09-13 18:55:10.321', NULL, 3, 3),
(7, 'CVE-2019-0708', '2026-09-14 11:20:15.654', NULL, 4, 4),
(8, 'CVE-2020-0601', '2026-09-15 13:35:40.789', NULL, 2, 5),
(9, 'CVE-2021-26855', '2026-09-16 15:10:55.987', NULL, 5, 2),
(10, 'CVE-2020-0796', '2026-09-17 08:45:16.432', NULL, 1, 1),
(11, 'CVE-2021-3156', '2026-09-08 10:15:30.123', NULL, 2, 3),
(12, 'CVE-2020-3452', '2026-09-09 11:45:50.567', NULL, 3, 4),
(13, 'CVE-2019-0708', '2026-09-10 13:22:10.234', NULL, 4, 2),
(14, 'CVE-2021-1675', '2026-09-11 15:30:45.890', NULL, 2, 5),
(15, 'CVE-2020-1938', '2026-09-12 09:40:25.765', NULL, 1, 1),
(16, 'CVE-2018-1234', '2026-09-13 14:55:10.321', NULL, 3, 3),
(17, 'CVE-2017-0143', '2026-09-14 16:20:15.654', NULL, 5, 4),
(18, 'CVE-2022-1234', '2026-09-15 18:35:40.789', NULL, 1, 2),
(19, 'CVE-2019-1458', '2026-09-16 19:10:55.987', NULL, 4, 3),
(20, 'CVE-2021-34527', '2026-09-17 11:25:16.432', NULL, 2, 4);

-- Alinea todas las secuencias con el mayor id insertado
SELECT setval('public.customers_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.customers), 0), 1), (SELECT count(*) > 0 FROM public.customers));
SELECT setval('public.alert_states_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.alert_states), 0), 1), (SELECT count(*) > 0 FROM public.alert_states));
SELECT setval('public.alert_severities_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.alert_severities), 0), 1), (SELECT count(*) > 0 FROM public.alert_severities));
SELECT setval('public.service_catalog_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.service_catalog), 0), 1), (SELECT count(*) > 0 FROM public.service_catalog));
SELECT setval('public.scan_runs_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.scan_runs), 0), 1), (SELECT count(*) > 0 FROM public.scan_runs));
SELECT setval('public.telegram_channels_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.telegram_channels), 0), 1), (SELECT count(*) > 0 FROM public.telegram_channels));
SELECT setval('public.blocklisted_domains_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.blocklisted_domains), 0), 1), (SELECT count(*) > 0 FROM public.blocklisted_domains));
SELECT setval('public.blocklisted_domains_top_scores_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.blocklisted_domains_top_scores), 0), 1), (SELECT count(*) > 0 FROM public.blocklisted_domains_top_scores));
SELECT setval('public.blocklisted_ip_addresses_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.blocklisted_ip_addresses), 0), 1), (SELECT count(*) > 0 FROM public.blocklisted_ip_addresses));
SELECT setval('public.blocklisted_ip_addresses_top_scores_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.blocklisted_ip_addresses_top_scores), 0), 1), (SELECT count(*) > 0 FROM public.blocklisted_ip_addresses_top_scores));
SELECT setval('public.monitored_domains_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.monitored_domains), 0), 1), (SELECT count(*) > 0 FROM public.monitored_domains));
SELECT setval('public.monitored_ip_addresses_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.monitored_ip_addresses), 0), 1), (SELECT count(*) > 0 FROM public.monitored_ip_addresses));
SELECT setval('public.monitored_keywords_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.monitored_keywords), 0), 1), (SELECT count(*) > 0 FROM public.monitored_keywords));
SELECT setval('public.google_dork_queries_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.google_dork_queries), 0), 1), (SELECT count(*) > 0 FROM public.google_dork_queries));
SELECT setval('public.shodan_dork_queries_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.shodan_dork_queries), 0), 1), (SELECT count(*) > 0 FROM public.shodan_dork_queries));
SELECT setval('public.twitter_dork_queries_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.twitter_dork_queries), 0), 1), (SELECT count(*) > 0 FROM public.twitter_dork_queries));
SELECT setval('public.github_commit_alerts_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.github_commit_alerts), 0), 1), (SELECT count(*) > 0 FROM public.github_commit_alerts));
SELECT setval('public.gitlab_project_alerts_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.gitlab_project_alerts), 0), 1), (SELECT count(*) > 0 FROM public.gitlab_project_alerts));
SELECT setval('public.google_search_alerts_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.google_search_alerts), 0), 1), (SELECT count(*) > 0 FROM public.google_search_alerts));
SELECT setval('public.intelx_leak_alerts_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.intelx_leak_alerts), 0), 1), (SELECT count(*) > 0 FROM public.intelx_leak_alerts));
SELECT setval('public.leaked_secret_alerts_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.leaked_secret_alerts), 0), 1), (SELECT count(*) > 0 FROM public.leaked_secret_alerts));
SELECT setval('public.telegram_message_alerts_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.telegram_message_alerts), 0), 1), (SELECT count(*) > 0 FROM public.telegram_message_alerts));
SELECT setval('public.twitter_post_alerts_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.twitter_post_alerts), 0), 1), (SELECT count(*) > 0 FROM public.twitter_post_alerts));
SELECT setval('public.typosquatting_alerts_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.typosquatting_alerts), 0), 1), (SELECT count(*) > 0 FROM public.typosquatting_alerts));
SELECT setval('public.certificate_alerts_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.certificate_alerts), 0), 1), (SELECT count(*) > 0 FROM public.certificate_alerts));
SELECT setval('public.defacement_alerts_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.defacement_alerts), 0), 1), (SELECT count(*) > 0 FROM public.defacement_alerts));
SELECT setval('public.shodan_legacy_alerts_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.shodan_legacy_alerts), 0), 1), (SELECT count(*) > 0 FROM public.shodan_legacy_alerts));
SELECT setval('public.shodan_host_alerts_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.shodan_host_alerts), 0), 1), (SELECT count(*) > 0 FROM public.shodan_host_alerts));
SELECT setval('public.shodan_port_alerts_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.shodan_port_alerts), 0), 1), (SELECT count(*) > 0 FROM public.shodan_port_alerts));
SELECT setval('public.shodan_vulnerability_alerts_id_seq', GREATEST(COALESCE((SELECT max(id) FROM public.shodan_vulnerability_alerts), 0), 1), (SELECT count(*) > 0 FROM public.shodan_vulnerability_alerts));

COMMIT;
