// @ts-nocheck
declare function isString(o: unknown): o is string;
declare function isUndefined(o: unknown): o is undefined;
declare function isNull(o: unknown): o is null;
declare function isObject<T>(o: unknown): o is T;
declare function isBoolean(o: unknown): o is boolean;
declare function isFunction(o: unknown): o is (...args: any[]) => any;
declare function isNumber(o: unknown): o is number;
declare function isBooleanStringLiteral(o: unknown): o is string;
declare const isArray: (arg: any) => arg is any[];
declare const isWebPlatform: () => boolean;
export { isString, isUndefined, isNull, isObject, isBoolean, isFunction, isNumber, isBooleanStringLiteral, isArray, isWebPlatform };
