# Usage

1. `$ ansible-playbook --inventory=SSH_HOST, --user=SSH_USER --private-key=~/.ssh/google_compute_engine --vault-password-file VAULT_PASSWORD_FILE --verbose site.yml`

2. Add a DNS record

3. Set up TLS via certbot with proxy_pass to an internal gcloud IP address
