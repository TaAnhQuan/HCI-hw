//
//  Generated code. Do not modify.
//  source: google/cloud/texttospeech/v1/cloud_tts.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// Gender of the voice as described in
/// [SSML voice element](https://www.w3.org/TR/speech-synthesis11/#edef_voice).
class SsmlVoiceGender extends $pb.ProtobufEnum {
  static const SsmlVoiceGender SSML_VOICE_GENDER_UNSPECIFIED = SsmlVoiceGender._(0, _omitEnumNames ? '' : 'SSML_VOICE_GENDER_UNSPECIFIED');
  static const SsmlVoiceGender MALE = SsmlVoiceGender._(1, _omitEnumNames ? '' : 'MALE');
  static const SsmlVoiceGender FEMALE = SsmlVoiceGender._(2, _omitEnumNames ? '' : 'FEMALE');
  static const SsmlVoiceGender NEUTRAL = SsmlVoiceGender._(3, _omitEnumNames ? '' : 'NEUTRAL');

  static const $core.List<SsmlVoiceGender> values = <SsmlVoiceGender> [
    SSML_VOICE_GENDER_UNSPECIFIED,
    MALE,
    FEMALE,
    NEUTRAL,
  ];

  static final $core.Map<$core.int, SsmlVoiceGender> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SsmlVoiceGender? valueOf($core.int value) => _byValue[value];

  const SsmlVoiceGender._($core.int v, $core.String n) : super(v, n);
}

/// Configuration to set up audio encoder. The encoding determines the output
/// audio format that we'd like.
class AudioEncoding extends $pb.ProtobufEnum {
  static const AudioEncoding AUDIO_ENCODING_UNSPECIFIED = AudioEncoding._(0, _omitEnumNames ? '' : 'AUDIO_ENCODING_UNSPECIFIED');
  static const AudioEncoding LINEAR16 = AudioEncoding._(1, _omitEnumNames ? '' : 'LINEAR16');
  static const AudioEncoding MP3 = AudioEncoding._(2, _omitEnumNames ? '' : 'MP3');
  static const AudioEncoding OGG_OPUS = AudioEncoding._(3, _omitEnumNames ? '' : 'OGG_OPUS');
  static const AudioEncoding MULAW = AudioEncoding._(5, _omitEnumNames ? '' : 'MULAW');
  static const AudioEncoding ALAW = AudioEncoding._(6, _omitEnumNames ? '' : 'ALAW');

  static const $core.List<AudioEncoding> values = <AudioEncoding> [
    AUDIO_ENCODING_UNSPECIFIED,
    LINEAR16,
    MP3,
    OGG_OPUS,
    MULAW,
    ALAW,
  ];

  static final $core.Map<$core.int, AudioEncoding> _byValue = $pb.ProtobufEnum.initByValue(values);
  static AudioEncoding? valueOf($core.int value) => _byValue[value];

  const AudioEncoding._($core.int v, $core.String n) : super(v, n);
}

/// The phonetic encoding of the phrase.
class CustomPronunciationParams_PhoneticEncoding extends $pb.ProtobufEnum {
  static const CustomPronunciationParams_PhoneticEncoding PHONETIC_ENCODING_UNSPECIFIED = CustomPronunciationParams_PhoneticEncoding._(0, _omitEnumNames ? '' : 'PHONETIC_ENCODING_UNSPECIFIED');
  static const CustomPronunciationParams_PhoneticEncoding PHONETIC_ENCODING_IPA = CustomPronunciationParams_PhoneticEncoding._(1, _omitEnumNames ? '' : 'PHONETIC_ENCODING_IPA');
  static const CustomPronunciationParams_PhoneticEncoding PHONETIC_ENCODING_X_SAMPA = CustomPronunciationParams_PhoneticEncoding._(2, _omitEnumNames ? '' : 'PHONETIC_ENCODING_X_SAMPA');

  static const $core.List<CustomPronunciationParams_PhoneticEncoding> values = <CustomPronunciationParams_PhoneticEncoding> [
    PHONETIC_ENCODING_UNSPECIFIED,
    PHONETIC_ENCODING_IPA,
    PHONETIC_ENCODING_X_SAMPA,
  ];

  static final $core.Map<$core.int, CustomPronunciationParams_PhoneticEncoding> _byValue = $pb.ProtobufEnum.initByValue(values);
  static CustomPronunciationParams_PhoneticEncoding? valueOf($core.int value) => _byValue[value];

  const CustomPronunciationParams_PhoneticEncoding._($core.int v, $core.String n) : super(v, n);
}

/// Deprecated. The usage of the synthesized audio. Usage does not affect
/// billing.
class CustomVoiceParams_ReportedUsage extends $pb.ProtobufEnum {
  static const CustomVoiceParams_ReportedUsage REPORTED_USAGE_UNSPECIFIED = CustomVoiceParams_ReportedUsage._(0, _omitEnumNames ? '' : 'REPORTED_USAGE_UNSPECIFIED');
  static const CustomVoiceParams_ReportedUsage REALTIME = CustomVoiceParams_ReportedUsage._(1, _omitEnumNames ? '' : 'REALTIME');
  static const CustomVoiceParams_ReportedUsage OFFLINE = CustomVoiceParams_ReportedUsage._(2, _omitEnumNames ? '' : 'OFFLINE');

  static const $core.List<CustomVoiceParams_ReportedUsage> values = <CustomVoiceParams_ReportedUsage> [
    REPORTED_USAGE_UNSPECIFIED,
    REALTIME,
    OFFLINE,
  ];

  static final $core.Map<$core.int, CustomVoiceParams_ReportedUsage> _byValue = $pb.ProtobufEnum.initByValue(values);
  static CustomVoiceParams_ReportedUsage? valueOf($core.int value) => _byValue[value];

  const CustomVoiceParams_ReportedUsage._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
