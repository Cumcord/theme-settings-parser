import "../dart_build/dist";

const parseFunc = window.parseThemeSettings;
delete window.parseThemeSettings;
export default parseFunc;