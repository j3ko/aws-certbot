class DomainList:
    def __init__(self, domains):
        self.original = domains
        self.lineage = self.parse(domains)

    def parse(self, domains):
        groups = domains.split(';')
        result = {}
        for doms in groups:
            items = doms.split(',')
            lineage = self.choose_lineagename(items[0].strip())
            result[lineage] = ','.join(i.strip() for i in items)
        return result

    def is_wildcard_domain(self, domain):
        wildcard_marker: Union[Text, bytes] = b"*."
        if isinstance(domain, str):
            wildcard_marker = u"*."
        return domain.startswith(wildcard_marker)

    def choose_lineagename(self, domain):
        if self.is_wildcard_domain(domain):
            return domain[2:]
        return domain

    def to_string(self):
        return '({0})'.format(self.original)
