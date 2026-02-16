// Info.plist에 추가하여 .vcf 파일 처리 지원
//
// CFBundleDocumentTypes:
// - CFBundleTypeName: vCard
//   CFBundleTypeRole: Viewer
//   LSHandlerRank: Alternate
//   LSItemContentTypes:
//     - public.vcard
//
// UTImportedTypeDeclarations 또는 UTExportedTypeDeclarations:
// - UTTypeIdentifier: public.vcard
//   UTTypeDescription: vCard Contact
//   UTTypeConformsTo:
//     - public.text
//   UTTypeTagSpecification:
//     public.filename-extension:
//       - vcf
//     public.mime-type:
//       - text/vcard
