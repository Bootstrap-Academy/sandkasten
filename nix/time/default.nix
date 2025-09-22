{ time }:

time.overrideAttrs (attrs: {
  patches = attrs.patches or [ ] ++ [ ./precision.patch ];
})
