users: let
  out = builtins.foldl' (b: a: let
    res = import ../users/${a}/config.nix;
    user = res // { 
      username = a;
    };
    out = b // { 
      ${a} = user; 
    };
  in
    out
  ) {} users;
in
  out
