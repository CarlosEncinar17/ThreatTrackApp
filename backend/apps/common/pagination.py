from rest_framework.pagination import PageNumberPagination


class StandardPagination(PageNumberPagination):
    """Paginacion por numero de pagina: 10 elementos por defecto, hasta 100 con ?page_size=."""

    page_size = 10
    page_size_query_param = "page_size"
    max_page_size = 100
