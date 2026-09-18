"""
Runner de pruebas para un proyecto cuyas tablas de negocio son `managed = False`.

Django no crea tablas de modelos no gestionados en la base de datos de pruebas, asi que
durante los tests se marcan como gestionados y se desactivan las migraciones para que las
tablas se creen directamente a partir de los modelos.
"""
from django.apps import apps
from django.conf import settings
from django.test.runner import DiscoverRunner


class _DisableMigrations(dict):
    def __contains__(self, item):
        return True

    def __getitem__(self, item):
        return None


class ManagedModelTestRunner(DiscoverRunner):
    def setup_test_environment(self, **kwargs):
        self._unmanaged_models = [m for m in apps.get_models() if not m._meta.managed]
        for model in self._unmanaged_models:
            model._meta.managed = True
        settings.MIGRATION_MODULES = _DisableMigrations()
        super().setup_test_environment(**kwargs)

    def teardown_test_environment(self, **kwargs):
        super().teardown_test_environment(**kwargs)
        for model in self._unmanaged_models:
            model._meta.managed = False
