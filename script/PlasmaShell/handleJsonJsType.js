(function (plasmaManager) {
  'use strict';
  const {} = plasmaManager;
  const handleJsonJsType = function (callbackFn, value) {
    switch (value._jsType) {
      case 'raw':
        return callbackFn.call(this, value.value);
      case 'undefined':
        return callbackFn.call(this, undefined);
      case 'if':
        let condition = value.condition;
        if (condition instanceof Function) condition = condition.call(this, callbackFn, value.value);
        if (condition) {
          return handleJsonJsType.call(this, callbackFn, value.value);
        } else {
          return undefined;
        }
      case 'eval':
        let {script, value: args} = value;
        const scriptValue = eval script;
        if (args === undefined) args = [];
        return handleJsonJsType.call(this, callbackFn, scriptValue.call(this, ...args));
      case undefined:
        return undefined;
      default:
        throw new TypeError(`Unknown _jsType: ''${prop._jsType}`);
    }
  };
  plasmaManager.handleJsonJsType = handleJsonJsType;
  return plasmaManager;
})
