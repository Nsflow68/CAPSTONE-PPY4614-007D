"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const common_1 = require("@nestjs/common");
const app_module_1 = require("./app.module");
async function bootstrap() {
    var _a;
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    app.setGlobalPrefix('v1');
    app.useGlobalPipes(new common_1.ValidationPipe({
        whitelist: true,
        transform: true,
    }));
    const port = (_a = process.env.PORT) !== null && _a !== void 0 ? _a : 3000;
    await app.listen(port);
    console.log(`🚀 Mi Refugio API escuchando en http://localhost:${port}/v1`);
}
bootstrap();
//# sourceMappingURL=main.js.map