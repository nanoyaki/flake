{ lib, ... }:

{
  singleAttrOf =
    elemType:
    (lib.types.attrsOf elemType)
    // {
      check = actual: (lib.isAttrs actual) && ((lib.lists.length (lib.attrValues actual)) == 1);
    };
}
