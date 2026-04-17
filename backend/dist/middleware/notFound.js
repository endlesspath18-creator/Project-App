"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.notFound = void 0;
const response_1 = require("../utils/response");
const notFound = (req, res, next) => {
    return (0, response_1.sendError)(res, 404, `Route not found: ${req.originalUrl}`);
};
exports.notFound = notFound;
