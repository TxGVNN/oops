(list (channel
       (name 'guxti)
       (branch "update-guix")
       (url "https://github.com/TxGVNN/guxti")
       (introduction
        (make-channel-introduction
         "34ce27aeadde4ab8b26802453628f713155c0e96"
         (openpgp-fingerprint
          "97EE 7685 F353 F3BB AAFC  D3DA 8D6C 190A CBFE 117C"))))

      (channel
       (name 'guix)
       (branch "emacs-team")
       (commit "0a50703abd5bfb27c7e130644db3045032604751")
       (url "https://codeberg.org/guix/guix.git")
       (introduction
        (make-channel-introduction
         "9edb3f66fd807b096b48283debdcddccfea34bad"
         (openpgp-fingerprint
          "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA")))))
