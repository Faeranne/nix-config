with builtins;
{
  splitFileName = filename: (let
    res = match "(.*)\\..*" filename;
    name = elemAt res 0;
  in
    trace res name
  );
}
