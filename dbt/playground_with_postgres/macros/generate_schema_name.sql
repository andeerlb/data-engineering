{% macro generate_schema_name(custom_schema_name, node) %}
    {# This macro generates the schema name for a given node. If a custom schema name is provided, it will use that; otherwise, it will default to the target schema defined in the dbt profile. #}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name }}
    {%- endif -%}

{% endmacro %}