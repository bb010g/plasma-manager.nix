(function (plasmaManager) {
  'use strict';
  const {} = plasmaManager;
  // Beginning of code from @ungap/structured-clone {{{
  // SPDX-License-Identifier: MIT
  // SPDX-FileCopyrightText: 2021, Andrea Giammarchi, @WebReflection
  const typeOf = function (value) {
    const type = typeof value;
    if (type !== 'object' || !value) return ['Primitive', type];
    const asString = {}.toString.call(value).slice(8, -1);
    switch (asString) {
      case 'Array': return ['Array', ''];
      case 'Object': return ['Object', ''];
      case 'Date': return ['Date', ''];
      case 'RegExp': return ['RegExp', ''];
      case 'Map': return ['Map', ''];
      case 'Set': return ['Set', ''];
    }
    if (asString.includes('Array')) return ['Array', asString];
    if (asString.includes('Error')) return ['Error', asString];
    return ['Object', asString];
  };
  // End of code from @ungap/structured-clone }}}
  plasmaManager.typeOf = typeOf;
  return plasmaManager;
})
