# GoPhish & Postmark Phishing Simulation Configuration Guide

This document explains how to wire GoPhish to Postmark as the SMTP relay, configure DNS for `skippycrm.nl`, and configure Microsoft 365 Defender so your authorized phishing simulations are delivered to employee inboxes.

## Architecture Overview
- GoPhish: builds campaigns, hosts landing pages, and sends email to the SMTP relay.
- Postmark: outgoing SMTP relay that signs and delivers your mail; provides DKIM/SPF guidance and a good sending reputation.
- DNS (skippycrm.nl): contains SPF/DKIM/Return-Path records that authorize Postmark to send on your behalf.
- Microsoft 365 Defender: must be configured with an Advanced Delivery / Phishing Simulation bypass for your sending domain and Postmark sending IPs so Defender doesn't block the simulation.

---

## Phase 1 — Postmark Account & Sending Domain
1. Create the Postmark account using your corporate address (e.g., `admin@fortune.nl`).
   - This makes support validation easier if you need to explain authorized phishing tests.
2. In Postmark, add a new **Sending Domain** and enter `skippycrm.nl`.
3. Postmark will show the DNS records you must add to `skippycrm.nl` to verify the domain. DO NOT guess these values — copy the exact records from the Postmark dashboard.
   - Typical items Postmark will ask you to add:
     - SPF include (Postmark will provide the exact include value to add to your SPF TXT record).
     - DKIM records (you will be given specific record names and values — sometimes as CNAMEs or TXT entries).
     - Return-Path / bounce handling entries (CNAME/TXT) as required.
4. Add those DNS records at the DNS host authoritative for `skippycrm.nl` and wait for propagation (10–60 minutes typically).
5. Click **Verify** in Postmark for the sending domain.

Notes:
- Always paste the exact values Postmark provides. Policy strings and key names vary by provider and account.
- If Postmark offers a choice between API and SMTP, you can use either; GoPhish supports SMTP easily.

---

## Phase 2 — DNS Records (conceptual example)
Make these edits in the `skippycrm.nl` zone. Replace the example values with the exact values Postmark gives you.

- SPF (TXT):
  - Example guidance: update or create a TXT record for `skippycrm.nl` to include Postmark. The exact string comes from Postmark, but your SPF may look like:
    - `v=spf1 include:_spf.google.com include:spf.mtasv.net ~all` (replace `spf.mtasv.net` with the include Postmark provides)
- DKIM:
  - Add the DKIM records exactly as given by Postmark (name/value pairs). These are needed for DKIM signature validation.
- Return-Path / Bounce CNAME or TXT:
  - Add whatever Postmark requests for proper bounce handling.

Verification command (optional): after DNS changes propagate, send a test and inspect headers to confirm SPF/DKIM passed.

---

## Phase 3 — Postmark SMTP Credentials for GoPhish
1. In Postmark, find **SMTP Credentials** for the server that corresponds to your sending domain.
   - Copy SMTP host, port, and credential values from the dashboard. (Postmark commonly exposes `smtp.postmarkapp.com` and port `587`, but always verify on the dashboard.)
2. In GoPhish, open **Sending Profiles** → **New Profile** and enter:
   - **Name:** Postmark Relay
   - **From Address:** an address on `skippycrm.nl` (e.g., `it-support@skippycrm.nl`)
   - **Host:** the Postmark SMTP host and port provided (e.g., `smtp.postmarkapp.com:587`) — use the value from Postmark.
   - **Username/Password:** the SMTP credentials from Postmark (or the API token if using API-based SMTP). Paste exactly.
3. Click **Send Test Email** from GoPhish. If the SMTP test fails, check firewall rules and that port 587 outbound is allowed.

---

## Phase 4 — Microsoft 365 Defender Advanced Delivery Bypass
Postmark deliverability alone won't prevent Defender from blocking obvious phishing content. Configure the bypass:
1. Log in to your Microsoft 365 Defender portal (security.microsoft.com) using an admin account for `fortune.nl`.
2. Go to **Email & collaboration** → **Policies & rules** → **Threat policies** → **Advanced delivery**.
3. Create a new **Phishing simulation** rule and add these items:
   - **Sending domain:** `skippycrm.nl` (or `phish.skippycrm.nl` if you use a subdomain).
   - **Sending IP addresses:** Add the sending IPs or ranges Postmark uses (ask Postmark support or check their docs for the IP list used by your account/region).
   - **Simulation URLs to allow:** Add the exact GoPhish landing page hostnames (e.g., `http://phish.skippycrm.nl/*`) so Safe Links and ATP don't rewrite or block them.
4. Save the rule and allow time for propagation (can take several hours across a tenant).

Important: Defender will only allow traffic that matches exactly what you configure. If Postmark uses a delivery IP not listed in the rule, Defender may still block or quarantine the mail.

---

## Phase 5 — GoPhish Campaign Setup
1. Landing Page:
   - Host your GoPhish landing page on a reachable public hostname or IP (e.g., `phish.skippycrm.nl`). Ensure DNS A record points to your GoPhish server.
2. Email Template:
   - Use `{{.URL}}` in templates for unique tracking links.
3. Sending Profile:
   - Select the `Postmark Relay` profile you created.
4. Users & Groups:
   - Start with a small test group (your own test accounts) before scaling to the company.
5. Launch the campaign and monitor results in GoPhish.

---

## Verification & Troubleshooting
- If mail is not delivered:
  - Check the GoPhish sending logs for SMTP errors.
  - Verify the SMTP credentials and outbound firewall rules (port 587/465/25).
  - Confirm SPF and DKIM pass by inspecting headers in a received test message (check `Authentication-Results` header).
  - Confirm Defender advanced delivery rules include the correct Postmark IPs and domain.
- If Postmark suspends or flags the account:
  - Open a support ticket from your corporate `@fortune.nl` account and explain the authorized simulation use-case. Provide the sending domain `skippycrm.nl` and the intended traffic profile.

---

## Security & Compliance Notes
- Always run simulations that are authorized by management and legal.
- Use a dedicated sending domain or subdomain for phishing tests (e.g., `skippycrm.nl` or `phish.skippycrm.nl`) to avoid collateral trust/reputation issues for your corporate domains.

---

## Next Steps (suggested)
- Add Postmark-provided DNS records into `skippycrm.nl` zone and verify in Postmark.
- Create the GoPhish sending profile and run a test to a single mailbox.
- Configure Microsoft 365 Defender Advanced Delivery to whitelist the Postmark IPs and `skippycrm.nl` as described above.

If you want, I can:
- Draft the exact DNS record edits for `skippycrm.nl` once you paste the Postmark DNS values here.
- Add the Postmark SMTP credentials into a test sending profile in GoPhish (I can provide the steps and a checklist you can follow).


---

File location: `c:\Users\noah\gophish\Phishing_Simulation_Postmark_Guide.md`