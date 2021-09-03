import unittest
from aws_certbot.domain_list import DomainList

class TestDomainList(unittest.TestCase):

    def test_initializer(self):
        domains = 'example.com,*.example.com'
        dlist = DomainList(domains)
        self.assertEqual(dlist.original, domains)

    def test_parse(self):
        domains = 'example.com,*.example.com'
        dlist = DomainList(domains)
        self.assertEqual(dlist.lineage, {
            'example.com': 'example.com,*.example.com'
        })

    def test_parse_reverse(self):
        domains = '*.example.com,example.com'
        dlist = DomainList(domains)
        self.assertEqual(dlist.lineage, {
            'example.com': '*.example.com,example.com'
        })

    def test_parse_wildcard(self):
        domains = '*.example.com'
        dlist = DomainList(domains)
        self.assertEqual(dlist.lineage, {
            'example.com': '*.example.com'
        })

    def test_parse_determanistic1(self):
        domains = 'aa.example.com,aab.example.com,bcd.example.com'
        dlist = DomainList(domains)
        self.assertEqual(dlist.lineage, {
            'aa.example.com': 'aa.example.com,aab.example.com,bcd.example.com'
        })

    def test_parse_determanistic2(self):
        domains = 'aab.example.com,aa.example.com,bcd.example.com'
        dlist = DomainList(domains)
        self.assertEqual(dlist.lineage, {
            'aab.example.com': 'aab.example.com,aa.example.com,bcd.example.com'
        })

    def test_parse_group(self):
        domains = 'foo.com,*.foo.com;bar.com,*.bar.com'
        dlist = DomainList(domains)
        self.assertEqual(dlist.lineage, {
            'foo.com': 'foo.com,*.foo.com',
            'bar.com': 'bar.com,*.bar.com'
        })

    def test_parse_reverse_group(self):
        domains = '*.foo.com,foo.com;*.bar.com,bar.com'
        dlist = DomainList(domains)
        self.assertEqual(dlist.lineage, {
            'foo.com': '*.foo.com,foo.com',
            'bar.com': '*.bar.com,bar.com'
        })

    def test_parse_wildcard_group(self):
        domains = '*.foo.com;*.bar.com'
        dlist = DomainList(domains)
        self.assertEqual(dlist.lineage, {
            'foo.com': '*.foo.com',
            'bar.com': '*.bar.com'
        })

    def test_parse_determanistic1_group(self):
        domains = 'aa.foo.com,aab.foo.com,bcd.foo.com;aa.bar.com,aab.bar.com,bcd.bar.com'
        dlist = DomainList(domains)
        self.assertEqual(dlist.lineage, {
            'aa.foo.com': 'aa.foo.com,aab.foo.com,bcd.foo.com',
            'aa.bar.com': 'aa.bar.com,aab.bar.com,bcd.bar.com'
        })

    def test_parse_determanistic2_group(self):
        domains = 'aab.foo.com,aa.foo.com,bcd.foo.com;aab.bar.com,aa.bar.com,bcd.bar.com'
        dlist = DomainList(domains)
        self.assertEqual(dlist.lineage, {
            'aab.foo.com': 'aab.foo.com,aa.foo.com,bcd.foo.com',
            'aab.bar.com': 'bar.com,aa.bar.com,bcd.bar.com'
        })

if __name__ == '__main__':
    unittest.main()
