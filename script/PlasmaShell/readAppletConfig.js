(function (plasmaManager) {
  'use strict';
  const {typeOf} = plasmaManager;
  const readAppletConfig = function (currentConfigGroup) {
    let savedCurrentConfigGroup = this.currentConfigGroup;
    print(`${JSON.stringify(typeOf(savedCurrentConfigGroup))}\n`); // TODO(bb010g): remove debug print
    if (savedCurrentConfigGroup !== undefined) savedCurrentConfigGroup = [...savedCurrentConfigGroup];
    this.currentConfigGroup = currentConfigGroup;
    const subConfigGroups = [...this.configGroups];
    const config = {};
    for (const configKey of this.configKeys) {
      const configValue = this.readConfig(configKey, undefined);
      if (configValue !== undefined) config[configKey] = configValue;
    }
    for (const subConfigGroup of subConfigGroups) {
      const subConfig = readAppletConfig.call(this, [...currentConfigGroup, subConfigGroup]);
      config[subConfigGroup] = subConfig;
    }
    this.currentConfigGroup = savedCurrentConfigGroup;
    return config;
  };
  plasmaManager.readAppletConfig = readAppletConfig;
  return plasmaManager;
})
