# GoPhish & Mailtrap Phishing Simulation Configuration Guide

This guide details the end-to-end setup for conducting authorized phishing simulations using GoPhish, Mailtrap (as the SMTP relay), and Microsoft 365 Defender.

## System Architecture: How It Connects
1. **GoPhish Server**: The command center. It hosts the administrative UI, serves the fake landing pages, and compiles the phishing emails.
2. **Mailtrap (SMTP Relay)**: GoPhish sends the outgoing email to Mailtrap via an SMTP connection. Mailtrap handles the cryptographic signing (DKIM) and uses isolated IP addresses to deliver the mail across the internet, protecting your GoPhish server's actual IP.
3. **DNS**: Your domain's DNS (`skippycrm.nl`) contains records (SPF, DKIM) that tell the internet "Mailtrap is authorized to send emails on our behalf."
4. **Microsoft 365 Defender**: The receiving gateway. It checks the DNS records to ensure the sender is authentic. Then, it checks an "Advanced Delivery" whitelist to realize this is an authorized simulation so it doesn't block the simulated malicious payload.
5. **Employee Inbox**: The email arrives safely in the user's inbox. When clicked, it routes back to the GoPhish server's external IP to track the click/login.

---

## Phase 1: Mailtrap Setup (SMTP Relay)
If you try to send emails directly from GoPhish (or via Google), they will likely be dropped. Mailtrap will route them professionally.

### 1. Configure the Sending Domain
1. Create a free account at [Mailtrap.io](https://mailtrap.io).
2. Navigate to **Email Sending** -> **Sending Domains** (Do *not* use Email Testing).
3. Click **Add Domain** and enter `skippycrm.nl`.
4. Mailtrap will generate a set of DNS records (usually CNAMEs for DKIM/Return-Path and a TXT record for SPF).

### 2. Update Your DNS Records
Update your `skippycrm.nl` DNS zone file with the records Mailtrap provided:
* **DKIM Records:** These act as a digital signature proving the email was actually sent by you.
* **SPF Record:** This will look something like `v=spf1 include:_spf.google.com include:send.mailtrap.link ~all`. It tells receivers that Mailtrap is allowed to send for your domain.
* *Wait 10-15 minutes for the DNS records to propagate, then click "Verify" in Mailtrap.*

### 3. Contact Mailtrap Support (Critical!)
Mailtrap has aggressive anti-abuse filters. 
1. Open a support ticket with Mailtrap immediately. 
2. **Message:** *"We are configuring an authorized internal phishing awareness simulation for our company using GoPhish. Please whitelist our account so your automated abuse filters do not suspend us when we send our simulated phishing templates."*

---

## Phase 2: Microsoft 365 Defender Setup (The Bypass)
Even with perfect DNS, Microsoft will read the email, see it looks like a phish, and quarantine it. You MUST tell Microsoft to expect it.

1. Go to the **Microsoft 365 Defender Portal** (security.microsoft.com).
2. Navigate to **Email & collaboration** > **Policies & rules** > **Threat policies** > **Advanced delivery**.
3. Select the **Phishing simulation** tab and click **Add**.
4. Configure the bypass rules:
   * **Domain:** Enter your sending domain (`skippycrm.nl`).
   * **Sending IPs:** Enter the public IP addresses that Mailtrap uses to send your outbound mail (you can usually find this in Mailtrap's documentation or support).
   * **Simulation URLs to allow:** Enter the exact URL(s) of the landing pages you configure in GoPhish (e.g., `http://phish.skippycrm.nl/*`). This stops M365 Safe Links from detonating the payload.
5. Save the policy. *Note: It can take up to 12 hours for Defender policies to fully propagate across a tenant.*

---

## Phase 3: GoPhish Configuration
Now that the pipes are connected and the filters are bypassed, configure GoPhish to send the traffic.

### 1. Setup the Sending Profile
1. In Mailtrap, go to **Email Sending** -> **SMTP/API Settings** and copy your SMTP credentials.
2. Open GoPhish and navigate to **Sending Profiles** -> **New Profile**.
3. **Name:** Mailtrap Relay
4. **From:** This can be anything on your verified domain, e.g., `IT Support <support@skippycrm.nl>`.
5. **Host:** `send.smtp.mailtrap.io:587` (verify exact hostname from Mailtrap).
6. **Username & Password:** Paste the credentials from Mailtrap.
7. Click **Send Test Email** to verify the connection.

### 2. Create the Campaign
1. **Landing Pages:** Create the fake login page. Ensure the "URL" points back to the public IP or subdomain of your GoPhish server (e.g., `http://phish.skippycrm.nl`). 
2. **Email Templates:** Design the phishing email. Use the `{{.URL}}` variable so GoPhish automatically inserts the unique tracking link for each target.
3. **Users & Groups:** Add your test targets (start with just your own email to test the M365 bypass).
4. **Campaigns:** Combine the Profile, Landing Page, Template, and Target Group, and launch the campaign!

---
## Troubleshooting Checklist if Emails Fail
- [ ] Did Mailtrap suspend the account for abuse? (Check Mailtrap dashboard).
- [ ] Did it land in Microsoft Quarantine? (The M365 Advanced Delivery policy either hasn't propagated, or the Mailtrap IPs/Domain don't match the policy exactly).
- [ ] Did GoPhish throw an SMTP error? (Check Mailtrap credentials and ensure port 587 is open on your GoPhish server firewall).