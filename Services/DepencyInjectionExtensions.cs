using Microsoft.Extensions.DependencyInjection;

public static class DepencyInjectionExtensions {
    public static IServiceCollection AddCustomServices(this IServiceCollection services) {
        services.AddSingleton<ICardReader, CardReader>();
        return services;
    }
}
