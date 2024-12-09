{ username, ... }:

{
  services.openssh = {
    enable = true;
    openFirewall = true;

    settings = {
      PasswordAuthentication = false;
      X11Forwarding = true;
    };
  };

  users.users.${username}.openssh.authorizedKeys = {
    keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDD98P0o9n9EBq6s6IKDWt68Qc7nlyKTf5EZuW5ILIi9W040MRSppGKwDcZxmvqwrDFksfJ3aICx2xIKtaOq3IXwphwWvNTU8OWKqwY7VuvSlpbsmE8dsBtnZtSbZT6TJ/btJWNcKuTyC6HFo0uZwuwF9TvNWgTSNAG7uhq8ZeajyYv6xUijgt1ipt6DnJuT0Jd6R3UVHAT+WN+punLpGjB6FFyDqKA/qGv4W7/8gq4s1MeckKu6HcVLujNqcFo6kfHSWOq1KoZQQW/uV8Jnmkcjdb/4hySHsg0SwFQLx+Nfg+arzwwUO6M1i3ixiYr1010EdCbJWiS0qdGKQTeZvdr9a8pJJ5V5nvengou6z9b57nkr+b7dy3rJ7wlOTfqPbDqVUY5L5NVGDqhXt/2silqipEG/+iEEU8ZivbeUQMZvGeXqd171JWFazFyH5N5ybwPMUDPmPVwf9gfj7rDFdhUIkNFzfOaQNaFDHypfakOl9xeTnKBc4PusSPuOd8Gcns= hana@DESKTOP-85CFN3S" # Windows
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRQIrYkayEFUjw6Ll2OqxvMUliL8NziSOJUOftHeaTvXYyzg+6n7UUqIFGZo7LM5CBK0B/J91MG9ey/xWbqikUKjkk170gypAQ2xA/ddWMcG0E+CcL8djNnukW4olaWStTInIQ3gVRVkVwN6pQIkBF17hy/7vV9WvW2dvTIlMY5+6wh+VgZVwK8y2NbyN+p1Kj1qNwKEXIU5/9e9r3aSHWkBzlPceUkf39JlHqCs5/mdLueArrUIJA70fRl/xRqDQknxBW6uR11uyVdM5pIHGSY7NlDTCFX1t0WXcvdgHTLWo4cvWADH8TYW0SFeyrqAmli6cO4QQtXBgf+nPAIkAwjpkQbFp8mT5Nce7f2Bs6o+RM2CGUxbRRX3PFpx5w+TZ/nEBdr3YO9dMbnkEgKmkMfDvoqnhoGlawkakLxT22+q3gAdLXEtAt4wEmX6xaBJJAfo0Nx+lPdlFno2YyCFftOut05lXpSB52WX6oegkudKhfjUiQfzGqzzpDnRPRIxk= felix@Huenerkrawathe" # Local
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMzjVKp+9/40ZNdwnOGkon6UODYEy1gtRmyh/HImB0vG hana@kuroyuri" # kuroyuri-primary
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP3poqMv85Pqb5gwZRZYN2BLW+OAiMT5ZA0tQHUo977W hana@shirayuri" # shirayuri-primary
    ];

    # i HATE this
    keyFiles = [
      ./keys/deployment.pub
    ];
  };

  services.fail2ban = {
    enable = true;
    maxretry = 2;
    bantime = "1h";
  };
}
