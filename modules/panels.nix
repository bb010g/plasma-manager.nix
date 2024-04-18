{ config, lib, pkgs, ... }:
let
  inherit (builtins) isList readFile toJSON toString;
  inherit (lib) boolToString concatMapStringsSep concatStringsSep optionalString types;
  inherit (pkgs) formats;

  cfg = config.programs.plasma;

  # Widget types
  widgetType = types.submodule {
    options = {
      name = lib.mkOption {
        type = types.str;
        example = "org.kde.plasma.kickoff";
        description = "The name of the widget to add.";
      };
      config = lib.mkOption {
        type = types.attrsOf formats.json.type;
        default = { };
        example = {
          General.icon = "nix-snowflake-white";
        };
        description = "Configuration settings for the widget, written using `Applet.writeConfig()`.";
      };
      panelConfig = lib.mkOption {
        type = types.attrsOf formats.json.type;
        default = { };
        example = {
          Configuration.PreloadWeight = "100";
        };
        description = "Configuration settings for the widget at the panel level, written using `Applet.writeConfig()`.";
      };
      props = lib.mkOption {
        type = types.attrsOf formats.json.type;
        default = { };
        description = "Direct configuration settings for the widget, assigned to the widget object.";
      };
    };
  };

  panelType = types.submodule ({ config, options, ... }: {
    options = {
      config = lib.mkOption {
        type = types.attrsOf formats.json.type;
        default = { };
        example = {
          General.AppletOrder = "1;2;3;4";
        };
        description = "Configuration settings for the panel, written using `Applet.writeConfig()`.";
      };
      props = lib.mkOption {
        type = types.attrsOf formats.json.type;
        default = { };
        description = "Direct configuration settings for the widget, assigned to the widget object.";
      };
      height = lib.mkOption {
        type = types.int;
        default = 32;
        description = "The height of the panel.";
      };
      offset = lib.mkOption {
        type = types.nullOr types.int;
        default = null;
        example = 100;
        description = "The offset of the panel from the anchor-point.";
      };
      minLength = lib.mkOption {
        type = types.nullOr types.int;
        default = null;
        example = 1000;
        description = "The minimum required length/width of the panel.";
      };
      maxLength = lib.mkOption {
        type = types.nullOr types.int;
        default = null;
        example = 1600;
        description = "The maximum allowed length/width of the panel.";
      };
      lengthMode = lib.mkOption {
        type = types.nullOr (types.enum ["fit" "fill" "custom"]);
        default =
          if config.minLength != null || config.maxLength != null then
            "custom"
          else
            null;
        defaultText = lib.literalExpression ''
          if ${options.minLength} != null || ${options.maxLength} != null then
            "custom"
          else
            null'';
        example = "fit";
        description = "(Plasma 6 only) The length mode of the panel. Defaults to `custom` if either `minLength` or `maxLength` is set.";
      };
      location = lib.mkOption {
        type = types.str;
        default = types.nullOr (types.enum [ "top" "bottom" "left" "right" "floating" ]);
        example = "left";
        description = "The location of the panel.";
      };
      alignment = lib.mkOption {
        type = types.nullOr (types.enum [ "left" "center" "right" ]);
        default = "center";
        example = "right";
        description = "The alignment of the panel.";
      };
      hiding = lib.mkOption {
        type = types.nullOr (types.enum [
          "none"
          "autohide"
          # Plasma 5 only
          "windowscover"
          "windowsbelow"
          # Plasma 6 only
          "dodgewindows"
          "normalpanel"
          "windowsgobelow"
        ]);
        default = null;
        example = "autohide";
        description = ''
          The hiding mode of the panel. Here windowscover and windowsbelow are
          plasma 5 only, while dodgewindows, windowsgobelow and normalpanel are
          plasma 6 only.
        '';
      };
      floating = lib.mkEnableOption "Enable or disable floating style (plasma 6 only).";
      widgets = lib.mkOption {
        type = types.listOf (types.either types.str types.widgetType);
        default = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          "org.kde.plasma.icontasks"
          "org.kde.plasma.marginsseperator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
          "org.kde.plasma.showdesktop"
        ];
        example = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.icontasks"
          "org.kde.plasma.marginsseperator"
          "org.kde.plasma.digitalclock"
        ];
        description = ''
          The widgets to use in the panel. To get the names, it may be useful
          to look in the share/plasma/plasmoids folder of the nix-package the
          widget/plasmoid is from. Some packages which include some
          widgets/plasmoids are for example plasma-desktop and
          plasma-workspace.
        '';
      };
      screen = lib.mkOption {
        type = types.int;
        default = 0;
        description = "The screen the panel should appear on";
      };
      extraSettings = lib.mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Extra lines to add to the layout.js. See
          https://develop.kde.org/docs/plasma/scripting/ for inspiration.
        '';
      };
    };
    config = {
      props.height = config.height;
      props.floating = config.floating;
      props.alignment = lib.mkIf (config.alignment != null) config.alignment;
      props.hiding = lib.mkIf (config.hiding != null) config.hiding;
      props.location = lib.mkIf (config.location != null) config.location;
      props.lengthMode = lib.mkIf (config.lengthMode != null) {
        _jsType = "eval";
        script = ''(value) => {_jsType: "if", condition: applicationVersion.split(".")[0] == 6, value}'';
        value = [ config.lengthMode ];
      };
      props.maximumLength = lib.mkIf (config.maxLength != null) config.maxLength;
      props.minimumLength = lib.mkIf (config.minLength != null) config.minLength;
      props.offset = lib.mkIf (config.minLength != null) config.offset;
      config."lastScreen[$i]" = lib.mkIf (config.screen != 0) config.screen;
    };
  });

  appletSetPropsJs = indent: props: ''
    ((props) => (applet) => {
    ${indent}  for (const propKey in props) {
    ${indent}    handleJsonJsType.call(this, function (prop) { return applet[propKey] = prop; }, props[propKey]);
    ${indent}  }
    ${indent}})(${toJSON props})'';

  appletWriteConfigJs = indent: config: ''
    ((config) => (applet) => {
    ${indent}  return writeAppletConfig.call(
    ${indent}    applet,
    ${indent}    function (writeConfigCallbackFn, currentConfigGroup, configKey, configValue) {
    ${indent}      return handleJsonJsType.call(
    ${indent}        this,
    ${indent}        function (configValue) { return writeConfigCallbackFn.call(this, configValue); },
    ${indent}        configValue,
    ${indent}      );
    ${indent}    },
    ${indent}    config,
    ${indent}  );
    ${indent}})(${toJSON config})'';

  surroundNonEmptyString = prefix: suffix: str:
    if str != "" then
      prefix + str + suffix
    else
      str;

  # list of panels -> bool
  # Checks if any panels have non-default screens. If any of them do we need
  # some hacky tricks to place them on their screens.
  anyNonDefaultScreens = builtins.any (panel: panel.screen != 0);

  # any value or null -> string -> string
  # If value is null, returns the empty string, otherwise returns the provided string
  stringIfNotNull = e: optionalString (e != null);

  # string -> string
  # Wrap a string in double quotes.
  escapeJsString = s: toJSON "${s}";

  # list of strings -> string
  # Converts a list of strings to a single string, that can be parsed as a string list in JavaScript
  toJsStringList = values: ''[${concatMapStringsSep ", " escapeJsString values}]'';

  # Generate writeConfig calls to include for a widget with additional
  # configurations.
  widgetWriteConfigJs = indent: widget: group: key: value: ''
    ((w) => {
    ${indent}  w.currentConfigGroup = ${toJsStringList (lib.splitString "/" group)};
    ${indent}  return w.writeConfig(${escapeJsString key}, ${
        if isList value then
          toJsStringList value
        else
          escapeJsString value
      });
    ${indent}})(${widget})'';
  # Generate the text for all of the configuration for a widget with additional
  # configurations.
  widgetWriteConfigsJs = indent: widget: config: lib.pipe config [
    (lib.mapAttrsToList (group: groupAttrs:
      lib.mapAttrsToList (key: value: "${widgetWriteConfigJs indent widget group key value};") groupAttrs
    ))
    lib.concatLists
    (concatStringsSep "\n${indent}")
  ];

  #
  # Functions to aid us creating a single panel in the layout.js
  #
  plasma6OnlyCmdJs = indent: cmd: ''
    if (applicationVersion.split(".")[0] == 6) {
    ${indent}  ${cmd}
    ${indent}}'';

  panelAddWidgetJs = indent: widget: ''panel.addWidget(${escapeJsString widget})'';

  panelAddConfiguredWidgetJs = indent: panelWidgetsJs: widget: ''
    ((ws) => {
    ${indent}  const w = ${panelAddWidgetJs "${indent}  " widget.name};
    ${indent}  ws[${escapeJsString widget}] = w;${
        surroundNonEmptyString "\n${indent}  " "\n" (stringIfNotNull widget.config (
          widgetWriteConfigsJs "${indent}  " "ws[${escapeJsString widget.name}]" widget.config
        ))
      }
    ${indent}  return w;
    ${indent}})(${panelWidgetsJs})'';

  panelToLayoutJs = panel: ''
    (() => {
    ${indent}  let panel = new Panel;
    ${indent}  ${appletSetPropsJs "${indent}  " panel.props}(panel);
    ${indent}  ${appletWriteConfigJs "${indent}  " panel.config}(panel);

    ${indent}  let panelWidgets = {};${
        surroundNonEmptyString "\n${indent}  " "\n" (concatMapStringsSep "\n${indent}  "
          (widget: ''${panelAddConfiguredWidgetJs "${indent}  " ''panelWidgets'' widget};'')
          panel.widgets)
      }${
        surroundNonEmptyString "\n\n${indent}  " "\n\n" (stringIfNotNull panel.extraSettings (
          panel.extraSettings
        ))
      }
    ${indent}  return {panel, panelWidgets};
    ${indent}})()'';
in
{
  options.programs.plasma.panels = lib.mkOption {
    type = types.listOf panelType;
    default = [ ];
  };

  config = lib.mkIf (cfg.enable && (lib.length cfg.panels) > 0) {
    programs.plasma.startup.desktopScript."apply_panels" = {
      preCommands = ''
        # We delete plasma-org.kde.plasma.desktop-appletsrc to hinder it
        # growing indefinitely. See:
        # https://github.com/pjones/plasma-manager/issues/76
        [ -f ${config.xdg.configHome}/plasma-org.kde.plasma.desktop-appletsrc ] && rm ${config.xdg.configHome}/plasma-org.kde.plasma.desktop-appletsrc
      '';
      text = ''
        // Utility functions
        const plasmaManager = {};
        void ${readFile ../script/PlasmaShell/typeOf.js}(plasmaManager);
        void ${readFile ../script/PlasmaShell/handleJsonJsType.js}(plasmaManager);
        void ${readFile ../script/PlasmaShell/writeAppletConfig.js}(plasmaManager);

        // Removes all existing panels
        panels().forEach((panel) => panel.remove());

        // Adds the panels${
          surroundNonEmptyString "\n" "\n" (concatMapStringsSep "\n"
            (panel: "${panelToLayoutJs "" panel};")
            config.programs.plasma.panels)
        }
      '';
      postCommands = lib.mkIf (anyNonDefaultScreens cfg.panels) ''
        if [ -f ${config.xdg.configHome}/plasma-org.kde.plasma.desktop-appletsrc ]; then
          sed -i 's/^lastScreen\\x5b$i\\x5d=/lastScreen[$i]=/' ${config.xdg.configHome}/plasma-org.kde.plasma.desktop-appletsrc
          # We sleep a second in order to prevent some bugs (like the incorrect height being set)
          sleep 1; nohup plasmashell --replace &
        fi
      '';
      priority = 2;
    };
  };
}

