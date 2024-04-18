(function (plasmaManager) {
  'use strict';
  const {typeOf} = plasmaManager;
  const writeAppletConfig = function (configValueCallbackFn, currentConfigGroup, config) {
    let savedCurrentConfigGroup = this.currentConfigGroup;
    if (savedCurrentConfigGroup !== undefined) savedCurrentConfigGroup = [...savedCurrentConfigGroup];
    this.currentConfigGroup = currentConfigGroup;
    const config = {};
    for (const configKey in config) {
      // const configValue = this.readConfig(configKey, undefined);
      let configValue = config[configKey];
      const [configValueObjectType, configValueType] = typeOf(configValue);
      switch (configValueObjectType) {
        case 'Object':
          for (const subConfigGroup in configValue) {
            const subConfig = configValue[subConfigGroup];
            void writeAppletConfig.call(this, configValueCallbackFn, [...currentConfigGroup, subConfigGroup], subConfig);
          }
          break;
        case 'Map':
          for (const [subConfigGroup, subConfig] of configValue) {
            void writeAppletConfig.call(this, configValueCallbackFn, [...currentConfigGroup, subConfigGroup], subConfig);
          }
          break;
        default:
          void configValueCallbackFn.call(
            this,
            function (configValue) { return this.writeConfig(configKey, configValue); },
            currentConfigGroup,
            configKey,
            configValue,
          );
      }
    }
    for (const subConfigGroup of subConfigGroups) {
      const subConfig = readAppletConfig.call(this, [...currentConfigGroup, subConfigGroup]);
      config[subConfigGroup] = subConfig;
    }
    this.currentConfigGroup = savedCurrentConfigGroup;
    return config;
  };
  plasmaManager.writeAppletConfig = writeAppletConfig;
  return plasmaManager;
})
