function LogFunctionExecution(target: any, propertyName: string, descriptor: PropertyDescriptor): void {
    const originalMethod = descriptor.value;
    descriptor.value = function (...args: any[]) {
        console.log(`Executing ${propertyName} with parameters:`, args);
        return originalMethod.apply(this, args);
    };
}

export { LogFunctionExecution }
