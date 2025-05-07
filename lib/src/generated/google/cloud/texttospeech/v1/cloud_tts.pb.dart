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

import 'cloud_tts.pbenum.dart';

export 'cloud_tts.pbenum.dart';

/// The top-level message sent by the client for the `ListVoices` method.
class ListVoicesRequest extends $pb.GeneratedMessage {
  factory ListVoicesRequest({
    $core.String? languageCode,
  }) {
    final $result = create();
    if (languageCode != null) {
      $result.languageCode = languageCode;
    }
    return $result;
  }
  ListVoicesRequest._() : super();
  factory ListVoicesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListVoicesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListVoicesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.cloud.texttospeech.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'languageCode')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListVoicesRequest clone() => ListVoicesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListVoicesRequest copyWith(void Function(ListVoicesRequest) updates) => super.copyWith((message) => updates(message as ListVoicesRequest)) as ListVoicesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListVoicesRequest create() => ListVoicesRequest._();
  ListVoicesRequest createEmptyInstance() => create();
  static $pb.PbList<ListVoicesRequest> createRepeated() => $pb.PbList<ListVoicesRequest>();
  @$core.pragma('dart2js:noInline')
  static ListVoicesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListVoicesRequest>(create);
  static ListVoicesRequest? _defaultInstance;

  /// Optional. Recommended.
  /// [BCP-47](https://www.rfc-editor.org/rfc/bcp/bcp47.txt) language tag.
  /// If not specified, the API will return all supported voices.
  /// If specified, the ListVoices call will only return voices that can be used
  /// to synthesize this language_code. For example, if you specify `"en-NZ"`,
  /// all `"en-NZ"` voices will be returned. If you specify `"no"`, both
  /// `"no-\*"` (Norwegian) and `"nb-\*"` (Norwegian Bokmal) voices will be
  /// returned.
  @$pb.TagNumber(1)
  $core.String get languageCode => $_getSZ(0);
  @$pb.TagNumber(1)
  set languageCode($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLanguageCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearLanguageCode() => clearField(1);
}

/// The message returned to the client by the `ListVoices` method.
class ListVoicesResponse extends $pb.GeneratedMessage {
  factory ListVoicesResponse({
    $core.Iterable<Voice>? voices,
  }) {
    final $result = create();
    if (voices != null) {
      $result.voices.addAll(voices);
    }
    return $result;
  }
  ListVoicesResponse._() : super();
  factory ListVoicesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListVoicesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListVoicesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.cloud.texttospeech.v1'), createEmptyInstance: create)
    ..pc<Voice>(1, _omitFieldNames ? '' : 'voices', $pb.PbFieldType.PM, subBuilder: Voice.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListVoicesResponse clone() => ListVoicesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListVoicesResponse copyWith(void Function(ListVoicesResponse) updates) => super.copyWith((message) => updates(message as ListVoicesResponse)) as ListVoicesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListVoicesResponse create() => ListVoicesResponse._();
  ListVoicesResponse createEmptyInstance() => create();
  static $pb.PbList<ListVoicesResponse> createRepeated() => $pb.PbList<ListVoicesResponse>();
  @$core.pragma('dart2js:noInline')
  static ListVoicesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListVoicesResponse>(create);
  static ListVoicesResponse? _defaultInstance;

  /// The list of voices.
  @$pb.TagNumber(1)
  $core.List<Voice> get voices => $_getList(0);
}

/// Description of a voice supported by the TTS service.
class Voice extends $pb.GeneratedMessage {
  factory Voice({
    $core.Iterable<$core.String>? languageCodes,
    $core.String? name,
    SsmlVoiceGender? ssmlGender,
    $core.int? naturalSampleRateHertz,
  }) {
    final $result = create();
    if (languageCodes != null) {
      $result.languageCodes.addAll(languageCodes);
    }
    if (name != null) {
      $result.name = name;
    }
    if (ssmlGender != null) {
      $result.ssmlGender = ssmlGender;
    }
    if (naturalSampleRateHertz != null) {
      $result.naturalSampleRateHertz = naturalSampleRateHertz;
    }
    return $result;
  }
  Voice._() : super();
  factory Voice.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Voice.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Voice', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.cloud.texttospeech.v1'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'languageCodes')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..e<SsmlVoiceGender>(3, _omitFieldNames ? '' : 'ssmlGender', $pb.PbFieldType.OE, defaultOrMaker: SsmlVoiceGender.SSML_VOICE_GENDER_UNSPECIFIED, valueOf: SsmlVoiceGender.valueOf, enumValues: SsmlVoiceGender.values)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'naturalSampleRateHertz', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Voice clone() => Voice()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Voice copyWith(void Function(Voice) updates) => super.copyWith((message) => updates(message as Voice)) as Voice;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Voice create() => Voice._();
  Voice createEmptyInstance() => create();
  static $pb.PbList<Voice> createRepeated() => $pb.PbList<Voice>();
  @$core.pragma('dart2js:noInline')
  static Voice getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Voice>(create);
  static Voice? _defaultInstance;

  /// The languages that this voice supports, expressed as
  /// [BCP-47](https://www.rfc-editor.org/rfc/bcp/bcp47.txt) language tags (e.g.
  /// "en-US", "es-419", "cmn-tw").
  @$pb.TagNumber(1)
  $core.List<$core.String> get languageCodes => $_getList(0);

  /// The name of this voice.  Each distinct voice has a unique name.
  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  /// The gender of this voice.
  @$pb.TagNumber(3)
  SsmlVoiceGender get ssmlGender => $_getN(2);
  @$pb.TagNumber(3)
  set ssmlGender(SsmlVoiceGender v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasSsmlGender() => $_has(2);
  @$pb.TagNumber(3)
  void clearSsmlGender() => clearField(3);

  /// The natural sample rate (in hertz) for this voice.
  @$pb.TagNumber(4)
  $core.int get naturalSampleRateHertz => $_getIZ(3);
  @$pb.TagNumber(4)
  set naturalSampleRateHertz($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasNaturalSampleRateHertz() => $_has(3);
  @$pb.TagNumber(4)
  void clearNaturalSampleRateHertz() => clearField(4);
}

/// Used for advanced voice options.
class AdvancedVoiceOptions extends $pb.GeneratedMessage {
  factory AdvancedVoiceOptions({
    $core.bool? lowLatencyJourneySynthesis,
  }) {
    final $result = create();
    if (lowLatencyJourneySynthesis != null) {
      $result.lowLatencyJourneySynthesis = lowLatencyJourneySynthesis;
    }
    return $result;
  }
  AdvancedVoiceOptions._() : super();
  factory AdvancedVoiceOptions.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AdvancedVoiceOptions.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AdvancedVoiceOptions', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.cloud.texttospeech.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'lowLatencyJourneySynthesis')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AdvancedVoiceOptions clone() => AdvancedVoiceOptions()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AdvancedVoiceOptions copyWith(void Function(AdvancedVoiceOptions) updates) => super.copyWith((message) => updates(message as AdvancedVoiceOptions)) as AdvancedVoiceOptions;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AdvancedVoiceOptions create() => AdvancedVoiceOptions._();
  AdvancedVoiceOptions createEmptyInstance() => create();
  static $pb.PbList<AdvancedVoiceOptions> createRepeated() => $pb.PbList<AdvancedVoiceOptions>();
  @$core.pragma('dart2js:noInline')
  static AdvancedVoiceOptions getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AdvancedVoiceOptions>(create);
  static AdvancedVoiceOptions? _defaultInstance;

  /// Only for Journey voices. If false, the synthesis will be context aware
  /// and have higher latency.
  @$pb.TagNumber(1)
  $core.bool get lowLatencyJourneySynthesis => $_getBF(0);
  @$pb.TagNumber(1)
  set lowLatencyJourneySynthesis($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLowLatencyJourneySynthesis() => $_has(0);
  @$pb.TagNumber(1)
  void clearLowLatencyJourneySynthesis() => clearField(1);
}

/// The top-level message sent by the client for the `SynthesizeSpeech` method.
class SynthesizeSpeechRequest extends $pb.GeneratedMessage {
  factory SynthesizeSpeechRequest({
    SynthesisInput? input,
    VoiceSelectionParams? voice,
    AudioConfig? audioConfig,
    AdvancedVoiceOptions? advancedVoiceOptions,
  }) {
    final $result = create();
    if (input != null) {
      $result.input = input;
    }
    if (voice != null) {
      $result.voice = voice;
    }
    if (audioConfig != null) {
      $result.audioConfig = audioConfig;
    }
    if (advancedVoiceOptions != null) {
      $result.advancedVoiceOptions = advancedVoiceOptions;
    }
    return $result;
  }
  SynthesizeSpeechRequest._() : super();
  factory SynthesizeSpeechRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SynthesizeSpeechRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SynthesizeSpeechRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.cloud.texttospeech.v1'), createEmptyInstance: create)
    ..aOM<SynthesisInput>(1, _omitFieldNames ? '' : 'input', subBuilder: SynthesisInput.create)
    ..aOM<VoiceSelectionParams>(2, _omitFieldNames ? '' : 'voice', subBuilder: VoiceSelectionParams.create)
    ..aOM<AudioConfig>(3, _omitFieldNames ? '' : 'audioConfig', subBuilder: AudioConfig.create)
    ..aOM<AdvancedVoiceOptions>(8, _omitFieldNames ? '' : 'advancedVoiceOptions', subBuilder: AdvancedVoiceOptions.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SynthesizeSpeechRequest clone() => SynthesizeSpeechRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SynthesizeSpeechRequest copyWith(void Function(SynthesizeSpeechRequest) updates) => super.copyWith((message) => updates(message as SynthesizeSpeechRequest)) as SynthesizeSpeechRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SynthesizeSpeechRequest create() => SynthesizeSpeechRequest._();
  SynthesizeSpeechRequest createEmptyInstance() => create();
  static $pb.PbList<SynthesizeSpeechRequest> createRepeated() => $pb.PbList<SynthesizeSpeechRequest>();
  @$core.pragma('dart2js:noInline')
  static SynthesizeSpeechRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SynthesizeSpeechRequest>(create);
  static SynthesizeSpeechRequest? _defaultInstance;

  /// Required. The Synthesizer requires either plain text or SSML as input.
  @$pb.TagNumber(1)
  SynthesisInput get input => $_getN(0);
  @$pb.TagNumber(1)
  set input(SynthesisInput v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasInput() => $_has(0);
  @$pb.TagNumber(1)
  void clearInput() => clearField(1);
  @$pb.TagNumber(1)
  SynthesisInput ensureInput() => $_ensure(0);

  /// Required. The desired voice of the synthesized audio.
  @$pb.TagNumber(2)
  VoiceSelectionParams get voice => $_getN(1);
  @$pb.TagNumber(2)
  set voice(VoiceSelectionParams v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasVoice() => $_has(1);
  @$pb.TagNumber(2)
  void clearVoice() => clearField(2);
  @$pb.TagNumber(2)
  VoiceSelectionParams ensureVoice() => $_ensure(1);

  /// Required. The configuration of the synthesized audio.
  @$pb.TagNumber(3)
  AudioConfig get audioConfig => $_getN(2);
  @$pb.TagNumber(3)
  set audioConfig(AudioConfig v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasAudioConfig() => $_has(2);
  @$pb.TagNumber(3)
  void clearAudioConfig() => clearField(3);
  @$pb.TagNumber(3)
  AudioConfig ensureAudioConfig() => $_ensure(2);

  /// Advanced voice options.
  @$pb.TagNumber(8)
  AdvancedVoiceOptions get advancedVoiceOptions => $_getN(3);
  @$pb.TagNumber(8)
  set advancedVoiceOptions(AdvancedVoiceOptions v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasAdvancedVoiceOptions() => $_has(3);
  @$pb.TagNumber(8)
  void clearAdvancedVoiceOptions() => clearField(8);
  @$pb.TagNumber(8)
  AdvancedVoiceOptions ensureAdvancedVoiceOptions() => $_ensure(3);
}

/// Pronunciation customization for a phrase.
class CustomPronunciationParams extends $pb.GeneratedMessage {
  factory CustomPronunciationParams({
    $core.String? phrase,
    CustomPronunciationParams_PhoneticEncoding? phoneticEncoding,
    $core.String? pronunciation,
  }) {
    final $result = create();
    if (phrase != null) {
      $result.phrase = phrase;
    }
    if (phoneticEncoding != null) {
      $result.phoneticEncoding = phoneticEncoding;
    }
    if (pronunciation != null) {
      $result.pronunciation = pronunciation;
    }
    return $result;
  }
  CustomPronunciationParams._() : super();
  factory CustomPronunciationParams.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CustomPronunciationParams.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CustomPronunciationParams', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.cloud.texttospeech.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'phrase')
    ..e<CustomPronunciationParams_PhoneticEncoding>(2, _omitFieldNames ? '' : 'phoneticEncoding', $pb.PbFieldType.OE, defaultOrMaker: CustomPronunciationParams_PhoneticEncoding.PHONETIC_ENCODING_UNSPECIFIED, valueOf: CustomPronunciationParams_PhoneticEncoding.valueOf, enumValues: CustomPronunciationParams_PhoneticEncoding.values)
    ..aOS(3, _omitFieldNames ? '' : 'pronunciation')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CustomPronunciationParams clone() => CustomPronunciationParams()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CustomPronunciationParams copyWith(void Function(CustomPronunciationParams) updates) => super.copyWith((message) => updates(message as CustomPronunciationParams)) as CustomPronunciationParams;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CustomPronunciationParams create() => CustomPronunciationParams._();
  CustomPronunciationParams createEmptyInstance() => create();
  static $pb.PbList<CustomPronunciationParams> createRepeated() => $pb.PbList<CustomPronunciationParams>();
  @$core.pragma('dart2js:noInline')
  static CustomPronunciationParams getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CustomPronunciationParams>(create);
  static CustomPronunciationParams? _defaultInstance;

  /// The phrase to which the customization will be applied.
  /// The phrase can be multiple words (in the case of proper nouns etc), but
  /// should not span to a whole sentence.
  @$pb.TagNumber(1)
  $core.String get phrase => $_getSZ(0);
  @$pb.TagNumber(1)
  set phrase($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPhrase() => $_has(0);
  @$pb.TagNumber(1)
  void clearPhrase() => clearField(1);

  /// The phonetic encoding of the phrase.
  @$pb.TagNumber(2)
  CustomPronunciationParams_PhoneticEncoding get phoneticEncoding => $_getN(1);
  @$pb.TagNumber(2)
  set phoneticEncoding(CustomPronunciationParams_PhoneticEncoding v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasPhoneticEncoding() => $_has(1);
  @$pb.TagNumber(2)
  void clearPhoneticEncoding() => clearField(2);

  /// The pronunciation of the phrase. This must be in the phonetic encoding
  /// specified above.
  @$pb.TagNumber(3)
  $core.String get pronunciation => $_getSZ(2);
  @$pb.TagNumber(3)
  set pronunciation($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPronunciation() => $_has(2);
  @$pb.TagNumber(3)
  void clearPronunciation() => clearField(3);
}

/// A collection of pronunciation customizations.
class CustomPronunciations extends $pb.GeneratedMessage {
  factory CustomPronunciations({
    $core.Iterable<CustomPronunciationParams>? pronunciations,
  }) {
    final $result = create();
    if (pronunciations != null) {
      $result.pronunciations.addAll(pronunciations);
    }
    return $result;
  }
  CustomPronunciations._() : super();
  factory CustomPronunciations.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CustomPronunciations.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CustomPronunciations', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.cloud.texttospeech.v1'), createEmptyInstance: create)
    ..pc<CustomPronunciationParams>(1, _omitFieldNames ? '' : 'pronunciations', $pb.PbFieldType.PM, subBuilder: CustomPronunciationParams.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CustomPronunciations clone() => CustomPronunciations()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CustomPronunciations copyWith(void Function(CustomPronunciations) updates) => super.copyWith((message) => updates(message as CustomPronunciations)) as CustomPronunciations;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CustomPronunciations create() => CustomPronunciations._();
  CustomPronunciations createEmptyInstance() => create();
  static $pb.PbList<CustomPronunciations> createRepeated() => $pb.PbList<CustomPronunciations>();
  @$core.pragma('dart2js:noInline')
  static CustomPronunciations getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CustomPronunciations>(create);
  static CustomPronunciations? _defaultInstance;

  /// The pronunciation customizations to be applied.
  @$pb.TagNumber(1)
  $core.List<CustomPronunciationParams> get pronunciations => $_getList(0);
}

/// A Multi-speaker turn.
class MultiSpeakerMarkup_Turn extends $pb.GeneratedMessage {
  factory MultiSpeakerMarkup_Turn({
    $core.String? speaker,
    $core.String? text,
  }) {
    final $result = create();
    if (speaker != null) {
      $result.speaker = speaker;
    }
    if (text != null) {
      $result.text = text;
    }
    return $result;
  }
  MultiSpeakerMarkup_Turn._() : super();
  factory MultiSpeakerMarkup_Turn.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MultiSpeakerMarkup_Turn.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultiSpeakerMarkup.Turn', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.cloud.texttospeech.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'speaker')
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MultiSpeakerMarkup_Turn clone() => MultiSpeakerMarkup_Turn()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MultiSpeakerMarkup_Turn copyWith(void Function(MultiSpeakerMarkup_Turn) updates) => super.copyWith((message) => updates(message as MultiSpeakerMarkup_Turn)) as MultiSpeakerMarkup_Turn;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MultiSpeakerMarkup_Turn create() => MultiSpeakerMarkup_Turn._();
  MultiSpeakerMarkup_Turn createEmptyInstance() => create();
  static $pb.PbList<MultiSpeakerMarkup_Turn> createRepeated() => $pb.PbList<MultiSpeakerMarkup_Turn>();
  @$core.pragma('dart2js:noInline')
  static MultiSpeakerMarkup_Turn getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MultiSpeakerMarkup_Turn>(create);
  static MultiSpeakerMarkup_Turn? _defaultInstance;

  /// Required. The speaker of the turn, for example, 'O' or 'Q'. Please refer
  /// to documentation for available speakers.
  @$pb.TagNumber(1)
  $core.String get speaker => $_getSZ(0);
  @$pb.TagNumber(1)
  set speaker($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSpeaker() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpeaker() => clearField(1);

  /// Required. The text to speak.
  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => clearField(2);
}

/// A collection of turns for multi-speaker synthesis.
class MultiSpeakerMarkup extends $pb.GeneratedMessage {
  factory MultiSpeakerMarkup({
    $core.Iterable<MultiSpeakerMarkup_Turn>? turns,
  }) {
    final $result = create();
    if (turns != null) {
      $result.turns.addAll(turns);
    }
    return $result;
  }
  MultiSpeakerMarkup._() : super();
  factory MultiSpeakerMarkup.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MultiSpeakerMarkup.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultiSpeakerMarkup', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.cloud.texttospeech.v1'), createEmptyInstance: create)
    ..pc<MultiSpeakerMarkup_Turn>(1, _omitFieldNames ? '' : 'turns', $pb.PbFieldType.PM, subBuilder: MultiSpeakerMarkup_Turn.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MultiSpeakerMarkup clone() => MultiSpeakerMarkup()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MultiSpeakerMarkup copyWith(void Function(MultiSpeakerMarkup) updates) => super.copyWith((message) => updates(message as MultiSpeakerMarkup)) as MultiSpeakerMarkup;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MultiSpeakerMarkup create() => MultiSpeakerMarkup._();
  MultiSpeakerMarkup createEmptyInstance() => create();
  static $pb.PbList<MultiSpeakerMarkup> createRepeated() => $pb.PbList<MultiSpeakerMarkup>();
  @$core.pragma('dart2js:noInline')
  static MultiSpeakerMarkup getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MultiSpeakerMarkup>(create);
  static MultiSpeakerMarkup? _defaultInstance;

  /// Required. Speaker turns.
  @$pb.TagNumber(1)
  $core.List<MultiSpeakerMarkup_Turn> get turns => $_getList(0);
}

enum SynthesisInput_InputSource {
  text, 
  ssml, 
  multiSpeakerMarkup, 
  notSet
}

/// Contains text input to be synthesized. Either `text` or `ssml` must be
/// supplied. Supplying both or neither returns
/// [google.rpc.Code.INVALID_ARGUMENT][google.rpc.Code.INVALID_ARGUMENT]. The
/// input size is limited to 5000 bytes.
class SynthesisInput extends $pb.GeneratedMessage {
  factory SynthesisInput({
    $core.String? text,
    $core.String? ssml,
    CustomPronunciations? customPronunciations,
    MultiSpeakerMarkup? multiSpeakerMarkup,
  }) {
    final $result = create();
    if (text != null) {
      $result.text = text;
    }
    if (ssml != null) {
      $result.ssml = ssml;
    }
    if (customPronunciations != null) {
      $result.customPronunciations = customPronunciations;
    }
    if (multiSpeakerMarkup != null) {
      $result.multiSpeakerMarkup = multiSpeakerMarkup;
    }
    return $result;
  }
  SynthesisInput._() : super();
  factory SynthesisInput.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SynthesisInput.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, SynthesisInput_InputSource> _SynthesisInput_InputSourceByTag = {
    1 : SynthesisInput_InputSource.text,
    2 : SynthesisInput_InputSource.ssml,
    4 : SynthesisInput_InputSource.multiSpeakerMarkup,
    0 : SynthesisInput_InputSource.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SynthesisInput', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.cloud.texttospeech.v1'), createEmptyInstance: create)
    ..oo(0, [1, 2, 4])
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..aOS(2, _omitFieldNames ? '' : 'ssml')
    ..aOM<CustomPronunciations>(3, _omitFieldNames ? '' : 'customPronunciations', subBuilder: CustomPronunciations.create)
    ..aOM<MultiSpeakerMarkup>(4, _omitFieldNames ? '' : 'multiSpeakerMarkup', subBuilder: MultiSpeakerMarkup.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SynthesisInput clone() => SynthesisInput()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SynthesisInput copyWith(void Function(SynthesisInput) updates) => super.copyWith((message) => updates(message as SynthesisInput)) as SynthesisInput;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SynthesisInput create() => SynthesisInput._();
  SynthesisInput createEmptyInstance() => create();
  static $pb.PbList<SynthesisInput> createRepeated() => $pb.PbList<SynthesisInput>();
  @$core.pragma('dart2js:noInline')
  static SynthesisInput getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SynthesisInput>(create);
  static SynthesisInput? _defaultInstance;

  SynthesisInput_InputSource whichInputSource() => _SynthesisInput_InputSourceByTag[$_whichOneof(0)]!;
  void clearInputSource() => clearField($_whichOneof(0));

  /// The raw text to be synthesized.
  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => clearField(1);

  /// The SSML document to be synthesized. The SSML document must be valid
  /// and well-formed. Otherwise the RPC will fail and return
  /// [google.rpc.Code.INVALID_ARGUMENT][google.rpc.Code.INVALID_ARGUMENT]. For
  /// more information, see
  /// [SSML](https://cloud.google.com/text-to-speech/docs/ssml).
  @$pb.TagNumber(2)
  $core.String get ssml => $_getSZ(1);
  @$pb.TagNumber(2)
  set ssml($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSsml() => $_has(1);
  @$pb.TagNumber(2)
  void clearSsml() => clearField(2);

  ///  Optional. The pronunciation customizations to be applied to the input. If
  ///  this is set, the input will be synthesized using the given pronunciation
  ///  customizations.
  ///
  ///  The initial support will be for EFIGS (English, French,
  ///  Italian, German, Spanish) languages, as provided in
  ///  VoiceSelectionParams. Journey and Instant Clone voices are
  ///  not supported yet.
  ///
  ///  In order to customize the pronunciation of a phrase, there must be an exact
  ///  match of the phrase in the input types. If using SSML, the phrase must not
  ///  be inside a phoneme tag (entirely or partially).
  @$pb.TagNumber(3)
  CustomPronunciations get customPronunciations => $_getN(2);
  @$pb.TagNumber(3)
  set customPronunciations(CustomPronunciations v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasCustomPronunciations() => $_has(2);
  @$pb.TagNumber(3)
  void clearCustomPronunciations() => clearField(3);
  @$pb.TagNumber(3)
  CustomPronunciations ensureCustomPronunciations() => $_ensure(2);

  /// The multi-speaker input to be synthesized. Only applicable for
  /// multi-speaker synthesis.
  @$pb.TagNumber(4)
  MultiSpeakerMarkup get multiSpeakerMarkup => $_getN(3);
  @$pb.TagNumber(4)
  set multiSpeakerMarkup(MultiSpeakerMarkup v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasMultiSpeakerMarkup() => $_has(3);
  @$pb.TagNumber(4)
  void clearMultiSpeakerMarkup() => clearField(4);
  @$pb.TagNumber(4)
  MultiSpeakerMarkup ensureMultiSpeakerMarkup() => $_ensure(3);
}

/// Description of which voice to use for a synthesis request.
class VoiceSelectionParams extends $pb.GeneratedMessage {
  factory VoiceSelectionParams({
    $core.String? languageCode,
    $core.String? name,
    SsmlVoiceGender? ssmlGender,
    CustomVoiceParams? customVoice,
    VoiceCloneParams? voiceClone,
  }) {
    final $result = create();
    if (languageCode != null) {
      $result.languageCode = languageCode;
    }
    if (name != null) {
      $result.name = name;
    }
    if (ssmlGender != null) {
      $result.ssmlGender = ssmlGender;
    }
    if (customVoice != null) {
      $result.customVoice = customVoice;
    }
    if (voiceClone != null) {
      $result.voiceClone = voiceClone;
    }
    return $result;
  }
  VoiceSelectionParams._() : super();
  factory VoiceSelectionParams.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VoiceSelectionParams.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoiceSelectionParams', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.cloud.texttospeech.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'languageCode')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..e<SsmlVoiceGender>(3, _omitFieldNames ? '' : 'ssmlGender', $pb.PbFieldType.OE, defaultOrMaker: SsmlVoiceGender.SSML_VOICE_GENDER_UNSPECIFIED, valueOf: SsmlVoiceGender.valueOf, enumValues: SsmlVoiceGender.values)
    ..aOM<CustomVoiceParams>(4, _omitFieldNames ? '' : 'customVoice', subBuilder: CustomVoiceParams.create)
    ..aOM<VoiceCloneParams>(5, _omitFieldNames ? '' : 'voiceClone', subBuilder: VoiceCloneParams.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VoiceSelectionParams clone() => VoiceSelectionParams()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VoiceSelectionParams copyWith(void Function(VoiceSelectionParams) updates) => super.copyWith((message) => updates(message as VoiceSelectionParams)) as VoiceSelectionParams;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoiceSelectionParams create() => VoiceSelectionParams._();
  VoiceSelectionParams createEmptyInstance() => create();
  static $pb.PbList<VoiceSelectionParams> createRepeated() => $pb.PbList<VoiceSelectionParams>();
  @$core.pragma('dart2js:noInline')
  static VoiceSelectionParams getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoiceSelectionParams>(create);
  static VoiceSelectionParams? _defaultInstance;

  /// Required. The language (and potentially also the region) of the voice
  /// expressed as a [BCP-47](https://www.rfc-editor.org/rfc/bcp/bcp47.txt)
  /// language tag, e.g. "en-US". This should not include a script tag (e.g. use
  /// "cmn-cn" rather than "cmn-Hant-cn"), because the script will be inferred
  /// from the input provided in the SynthesisInput.  The TTS service
  /// will use this parameter to help choose an appropriate voice.  Note that
  /// the TTS service may choose a voice with a slightly different language code
  /// than the one selected; it may substitute a different region
  /// (e.g. using en-US rather than en-CA if there isn't a Canadian voice
  /// available), or even a different language, e.g. using "nb" (Norwegian
  /// Bokmal) instead of "no" (Norwegian)".
  @$pb.TagNumber(1)
  $core.String get languageCode => $_getSZ(0);
  @$pb.TagNumber(1)
  set languageCode($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLanguageCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearLanguageCode() => clearField(1);

  /// The name of the voice. If both the name and the gender are not set,
  /// the service will choose a voice based on the other parameters such as
  /// language_code.
  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  /// The preferred gender of the voice. If not set, the service will
  /// choose a voice based on the other parameters such as language_code and
  /// name. Note that this is only a preference, not requirement; if a
  /// voice of the appropriate gender is not available, the synthesizer should
  /// substitute a voice with a different gender rather than failing the request.
  @$pb.TagNumber(3)
  SsmlVoiceGender get ssmlGender => $_getN(2);
  @$pb.TagNumber(3)
  set ssmlGender(SsmlVoiceGender v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasSsmlGender() => $_has(2);
  @$pb.TagNumber(3)
  void clearSsmlGender() => clearField(3);

  /// The configuration for a custom voice. If [CustomVoiceParams.model] is set,
  /// the service will choose the custom voice matching the specified
  /// configuration.
  @$pb.TagNumber(4)
  CustomVoiceParams get customVoice => $_getN(3);
  @$pb.TagNumber(4)
  set customVoice(CustomVoiceParams v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasCustomVoice() => $_has(3);
  @$pb.TagNumber(4)
  void clearCustomVoice() => clearField(4);
  @$pb.TagNumber(4)
  CustomVoiceParams ensureCustomVoice() => $_ensure(3);

  /// Optional. The configuration for a voice clone. If
  /// [VoiceCloneParams.voice_clone_key] is set, the service will choose the
  /// voice clone matching the specified configuration.
  @$pb.TagNumber(5)
  VoiceCloneParams get voiceClone => $_getN(4);
  @$pb.TagNumber(5)
  set voiceClone(VoiceCloneParams v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasVoiceClone() => $_has(4);
  @$pb.TagNumber(5)
  void clearVoiceClone() => clearField(5);
  @$pb.TagNumber(5)
  VoiceCloneParams ensureVoiceClone() => $_ensure(4);
}

/// Description of audio data to be synthesized.
class AudioConfig extends $pb.GeneratedMessage {
  factory AudioConfig({
    AudioEncoding? audioEncoding,
    $core.double? speakingRate,
    $core.double? pitch,
    $core.double? volumeGainDb,
    $core.int? sampleRateHertz,
    $core.Iterable<$core.String>? effectsProfileId,
  }) {
    final $result = create();
    if (audioEncoding != null) {
      $result.audioEncoding = audioEncoding;
    }
    if (speakingRate != null) {
      $result.speakingRate = speakingRate;
    }
    if (pitch != null) {
      $result.pitch = pitch;
    }
    if (volumeGainDb != null) {
      $result.volumeGainDb = volumeGainDb;
    }
    if (sampleRateHertz != null) {
      $result.sampleRateHertz = sampleRateHertz;
    }
    if (effectsProfileId != null) {
      $result.effectsProfileId.addAll(effectsProfileId);
    }
    return $result;
  }
  AudioConfig._() : super();
  factory AudioConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AudioConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AudioConfig', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.cloud.texttospeech.v1'), createEmptyInstance: create)
    ..e<AudioEncoding>(1, _omitFieldNames ? '' : 'audioEncoding', $pb.PbFieldType.OE, defaultOrMaker: AudioEncoding.AUDIO_ENCODING_UNSPECIFIED, valueOf: AudioEncoding.valueOf, enumValues: AudioEncoding.values)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'speakingRate', $pb.PbFieldType.OD)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'pitch', $pb.PbFieldType.OD)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'volumeGainDb', $pb.PbFieldType.OD)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'sampleRateHertz', $pb.PbFieldType.O3)
    ..pPS(6, _omitFieldNames ? '' : 'effectsProfileId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AudioConfig clone() => AudioConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AudioConfig copyWith(void Function(AudioConfig) updates) => super.copyWith((message) => updates(message as AudioConfig)) as AudioConfig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AudioConfig create() => AudioConfig._();
  AudioConfig createEmptyInstance() => create();
  static $pb.PbList<AudioConfig> createRepeated() => $pb.PbList<AudioConfig>();
  @$core.pragma('dart2js:noInline')
  static AudioConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AudioConfig>(create);
  static AudioConfig? _defaultInstance;

  /// Required. The format of the audio byte stream.
  @$pb.TagNumber(1)
  AudioEncoding get audioEncoding => $_getN(0);
  @$pb.TagNumber(1)
  set audioEncoding(AudioEncoding v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasAudioEncoding() => $_has(0);
  @$pb.TagNumber(1)
  void clearAudioEncoding() => clearField(1);

  /// Optional. Input only. Speaking rate/speed, in the range [0.25, 4.0]. 1.0 is
  /// the normal native speed supported by the specific voice. 2.0 is twice as
  /// fast, and 0.5 is half as fast. If unset(0.0), defaults to the native 1.0
  /// speed. Any other values < 0.25 or > 4.0 will return an error.
  @$pb.TagNumber(2)
  $core.double get speakingRate => $_getN(1);
  @$pb.TagNumber(2)
  set speakingRate($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSpeakingRate() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpeakingRate() => clearField(2);

  /// Optional. Input only. Speaking pitch, in the range [-20.0, 20.0]. 20 means
  /// increase 20 semitones from the original pitch. -20 means decrease 20
  /// semitones from the original pitch.
  @$pb.TagNumber(3)
  $core.double get pitch => $_getN(2);
  @$pb.TagNumber(3)
  set pitch($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPitch() => $_has(2);
  @$pb.TagNumber(3)
  void clearPitch() => clearField(3);

  /// Optional. Input only. Volume gain (in dB) of the normal native volume
  /// supported by the specific voice, in the range [-96.0, 16.0]. If unset, or
  /// set to a value of 0.0 (dB), will play at normal native signal amplitude. A
  /// value of -6.0 (dB) will play at approximately half the amplitude of the
  /// normal native signal amplitude. A value of +6.0 (dB) will play at
  /// approximately twice the amplitude of the normal native signal amplitude.
  /// Strongly recommend not to exceed +10 (dB) as there's usually no effective
  /// increase in loudness for any value greater than that.
  @$pb.TagNumber(4)
  $core.double get volumeGainDb => $_getN(3);
  @$pb.TagNumber(4)
  set volumeGainDb($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasVolumeGainDb() => $_has(3);
  @$pb.TagNumber(4)
  void clearVolumeGainDb() => clearField(4);

  /// Optional. The synthesis sample rate (in hertz) for this audio. When this is
  /// specified in SynthesizeSpeechRequest, if this is different from the voice's
  /// natural sample rate, then the synthesizer will honor this request by
  /// converting to the desired sample rate (which might result in worse audio
  /// quality), unless the specified sample rate is not supported for the
  /// encoding chosen, in which case it will fail the request and return
  /// [google.rpc.Code.INVALID_ARGUMENT][google.rpc.Code.INVALID_ARGUMENT].
  @$pb.TagNumber(5)
  $core.int get sampleRateHertz => $_getIZ(4);
  @$pb.TagNumber(5)
  set sampleRateHertz($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSampleRateHertz() => $_has(4);
  @$pb.TagNumber(5)
  void clearSampleRateHertz() => clearField(5);

  /// Optional. Input only. An identifier which selects 'audio effects' profiles
  /// that are applied on (post synthesized) text to speech. Effects are applied
  /// on top of each other in the order they are given. See
  /// [audio
  /// profiles](https://cloud.google.com/text-to-speech/docs/audio-profiles) for
  /// current supported profile ids.
  @$pb.TagNumber(6)
  $core.List<$core.String> get effectsProfileId => $_getList(5);
}

/// Description of the custom voice to be synthesized.
class CustomVoiceParams extends $pb.GeneratedMessage {
  factory CustomVoiceParams({
    $core.String? model,
  @$core.Deprecated('This field is deprecated.')
    CustomVoiceParams_ReportedUsage? reportedUsage,
  }) {
    final $result = create();
    if (model != null) {
      $result.model = model;
    }
    if (reportedUsage != null) {
      // ignore: deprecated_member_use_from_same_package
      $result.reportedUsage = reportedUsage;
    }
    return $result;
  }
  CustomVoiceParams._() : super();
  factory CustomVoiceParams.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CustomVoiceParams.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CustomVoiceParams', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.cloud.texttospeech.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'model')
    ..e<CustomVoiceParams_ReportedUsage>(3, _omitFieldNames ? '' : 'reportedUsage', $pb.PbFieldType.OE, defaultOrMaker: CustomVoiceParams_ReportedUsage.REPORTED_USAGE_UNSPECIFIED, valueOf: CustomVoiceParams_ReportedUsage.valueOf, enumValues: CustomVoiceParams_ReportedUsage.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CustomVoiceParams clone() => CustomVoiceParams()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CustomVoiceParams copyWith(void Function(CustomVoiceParams) updates) => super.copyWith((message) => updates(message as CustomVoiceParams)) as CustomVoiceParams;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CustomVoiceParams create() => CustomVoiceParams._();
  CustomVoiceParams createEmptyInstance() => create();
  static $pb.PbList<CustomVoiceParams> createRepeated() => $pb.PbList<CustomVoiceParams>();
  @$core.pragma('dart2js:noInline')
  static CustomVoiceParams getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CustomVoiceParams>(create);
  static CustomVoiceParams? _defaultInstance;

  /// Required. The name of the AutoML model that synthesizes the custom voice.
  @$pb.TagNumber(1)
  $core.String get model => $_getSZ(0);
  @$pb.TagNumber(1)
  set model($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasModel() => $_has(0);
  @$pb.TagNumber(1)
  void clearModel() => clearField(1);

  /// Optional. Deprecated. The usage of the synthesized audio to be reported.
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(3)
  CustomVoiceParams_ReportedUsage get reportedUsage => $_getN(1);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(3)
  set reportedUsage(CustomVoiceParams_ReportedUsage v) { setField(3, v); }
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(3)
  $core.bool hasReportedUsage() => $_has(1);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(3)
  void clearReportedUsage() => clearField(3);
}

/// The configuration of Voice Clone feature.
class VoiceCloneParams extends $pb.GeneratedMessage {
  factory VoiceCloneParams({
    $core.String? voiceCloningKey,
  }) {
    final $result = create();
    if (voiceCloningKey != null) {
      $result.voiceCloningKey = voiceCloningKey;
    }
    return $result;
  }
  VoiceCloneParams._() : super();
  factory VoiceCloneParams.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VoiceCloneParams.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VoiceCloneParams', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.cloud.texttospeech.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'voiceCloningKey')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VoiceCloneParams clone() => VoiceCloneParams()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VoiceCloneParams copyWith(void Function(VoiceCloneParams) updates) => super.copyWith((message) => updates(message as VoiceCloneParams)) as VoiceCloneParams;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoiceCloneParams create() => VoiceCloneParams._();
  VoiceCloneParams createEmptyInstance() => create();
  static $pb.PbList<VoiceCloneParams> createRepeated() => $pb.PbList<VoiceCloneParams>();
  @$core.pragma('dart2js:noInline')
  static VoiceCloneParams getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoiceCloneParams>(create);
  static VoiceCloneParams? _defaultInstance;

  /// Required. Created by GenerateVoiceCloningKey.
  @$pb.TagNumber(1)
  $core.String get voiceCloningKey => $_getSZ(0);
  @$pb.TagNumber(1)
  set voiceCloningKey($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVoiceCloningKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearVoiceCloningKey() => clearField(1);
}

/// The message returned to the client by the `SynthesizeSpeech` method.
class SynthesizeSpeechResponse extends $pb.GeneratedMessage {
  factory SynthesizeSpeechResponse({
    $core.List<$core.int>? audioContent,
  }) {
    final $result = create();
    if (audioContent != null) {
      $result.audioContent = audioContent;
    }
    return $result;
  }
  SynthesizeSpeechResponse._() : super();
  factory SynthesizeSpeechResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SynthesizeSpeechResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SynthesizeSpeechResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.cloud.texttospeech.v1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'audioContent', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SynthesizeSpeechResponse clone() => SynthesizeSpeechResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SynthesizeSpeechResponse copyWith(void Function(SynthesizeSpeechResponse) updates) => super.copyWith((message) => updates(message as SynthesizeSpeechResponse)) as SynthesizeSpeechResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SynthesizeSpeechResponse create() => SynthesizeSpeechResponse._();
  SynthesizeSpeechResponse createEmptyInstance() => create();
  static $pb.PbList<SynthesizeSpeechResponse> createRepeated() => $pb.PbList<SynthesizeSpeechResponse>();
  @$core.pragma('dart2js:noInline')
  static SynthesizeSpeechResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SynthesizeSpeechResponse>(create);
  static SynthesizeSpeechResponse? _defaultInstance;

  /// The audio data bytes encoded as specified in the request, including the
  /// header for encodings that are wrapped in containers (e.g. MP3, OGG_OPUS).
  /// For LINEAR16 audio, we include the WAV header. Note: as
  /// with all bytes fields, protobuffers use a pure binary representation,
  /// whereas JSON representations use base64.
  @$pb.TagNumber(1)
  $core.List<$core.int> get audioContent => $_getN(0);
  @$pb.TagNumber(1)
  set audioContent($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAudioContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearAudioContent() => clearField(1);
}

/// Provides configuration information for the StreamingSynthesize request.
class StreamingSynthesizeConfig extends $pb.GeneratedMessage {
  factory StreamingSynthesizeConfig({
    VoiceSelectionParams? voice,
  }) {
    final $result = create();
    if (voice != null) {
      $result.voice = voice;
    }
    return $result;
  }
  StreamingSynthesizeConfig._() : super();
  factory StreamingSynthesizeConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StreamingSynthesizeConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StreamingSynthesizeConfig', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.cloud.texttospeech.v1'), createEmptyInstance: create)
    ..aOM<VoiceSelectionParams>(1, _omitFieldNames ? '' : 'voice', subBuilder: VoiceSelectionParams.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StreamingSynthesizeConfig clone() => StreamingSynthesizeConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StreamingSynthesizeConfig copyWith(void Function(StreamingSynthesizeConfig) updates) => super.copyWith((message) => updates(message as StreamingSynthesizeConfig)) as StreamingSynthesizeConfig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamingSynthesizeConfig create() => StreamingSynthesizeConfig._();
  StreamingSynthesizeConfig createEmptyInstance() => create();
  static $pb.PbList<StreamingSynthesizeConfig> createRepeated() => $pb.PbList<StreamingSynthesizeConfig>();
  @$core.pragma('dart2js:noInline')
  static StreamingSynthesizeConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StreamingSynthesizeConfig>(create);
  static StreamingSynthesizeConfig? _defaultInstance;

  /// Required. The desired voice of the synthesized audio.
  @$pb.TagNumber(1)
  VoiceSelectionParams get voice => $_getN(0);
  @$pb.TagNumber(1)
  set voice(VoiceSelectionParams v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasVoice() => $_has(0);
  @$pb.TagNumber(1)
  void clearVoice() => clearField(1);
  @$pb.TagNumber(1)
  VoiceSelectionParams ensureVoice() => $_ensure(0);
}

enum StreamingSynthesisInput_InputSource {
  text, 
  notSet
}

/// Input to be synthesized.
class StreamingSynthesisInput extends $pb.GeneratedMessage {
  factory StreamingSynthesisInput({
    $core.String? text,
  }) {
    final $result = create();
    if (text != null) {
      $result.text = text;
    }
    return $result;
  }
  StreamingSynthesisInput._() : super();
  factory StreamingSynthesisInput.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StreamingSynthesisInput.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, StreamingSynthesisInput_InputSource> _StreamingSynthesisInput_InputSourceByTag = {
    1 : StreamingSynthesisInput_InputSource.text,
    0 : StreamingSynthesisInput_InputSource.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StreamingSynthesisInput', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.cloud.texttospeech.v1'), createEmptyInstance: create)
    ..oo(0, [1])
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StreamingSynthesisInput clone() => StreamingSynthesisInput()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StreamingSynthesisInput copyWith(void Function(StreamingSynthesisInput) updates) => super.copyWith((message) => updates(message as StreamingSynthesisInput)) as StreamingSynthesisInput;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamingSynthesisInput create() => StreamingSynthesisInput._();
  StreamingSynthesisInput createEmptyInstance() => create();
  static $pb.PbList<StreamingSynthesisInput> createRepeated() => $pb.PbList<StreamingSynthesisInput>();
  @$core.pragma('dart2js:noInline')
  static StreamingSynthesisInput getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StreamingSynthesisInput>(create);
  static StreamingSynthesisInput? _defaultInstance;

  StreamingSynthesisInput_InputSource whichInputSource() => _StreamingSynthesisInput_InputSourceByTag[$_whichOneof(0)]!;
  void clearInputSource() => clearField($_whichOneof(0));

  /// The raw text to be synthesized. It is recommended that each input
  /// contains complete, terminating sentences, as this will likely result in
  /// better prosody in the output audio. That being said, users are free to
  /// input text however they please.
  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => clearField(1);
}

enum StreamingSynthesizeRequest_StreamingRequest {
  streamingConfig, 
  input, 
  notSet
}

/// Request message for the `StreamingSynthesize` method. Multiple
/// `StreamingSynthesizeRequest` messages are sent in one call.
/// The first message must contain a `streaming_config` that
/// fully specifies the request configuration and must not contain `input`. All
/// subsequent messages must only have `input` set.
class StreamingSynthesizeRequest extends $pb.GeneratedMessage {
  factory StreamingSynthesizeRequest({
    StreamingSynthesizeConfig? streamingConfig,
    StreamingSynthesisInput? input,
  }) {
    final $result = create();
    if (streamingConfig != null) {
      $result.streamingConfig = streamingConfig;
    }
    if (input != null) {
      $result.input = input;
    }
    return $result;
  }
  StreamingSynthesizeRequest._() : super();
  factory StreamingSynthesizeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StreamingSynthesizeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, StreamingSynthesizeRequest_StreamingRequest> _StreamingSynthesizeRequest_StreamingRequestByTag = {
    1 : StreamingSynthesizeRequest_StreamingRequest.streamingConfig,
    2 : StreamingSynthesizeRequest_StreamingRequest.input,
    0 : StreamingSynthesizeRequest_StreamingRequest.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StreamingSynthesizeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.cloud.texttospeech.v1'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<StreamingSynthesizeConfig>(1, _omitFieldNames ? '' : 'streamingConfig', subBuilder: StreamingSynthesizeConfig.create)
    ..aOM<StreamingSynthesisInput>(2, _omitFieldNames ? '' : 'input', subBuilder: StreamingSynthesisInput.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StreamingSynthesizeRequest clone() => StreamingSynthesizeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StreamingSynthesizeRequest copyWith(void Function(StreamingSynthesizeRequest) updates) => super.copyWith((message) => updates(message as StreamingSynthesizeRequest)) as StreamingSynthesizeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamingSynthesizeRequest create() => StreamingSynthesizeRequest._();
  StreamingSynthesizeRequest createEmptyInstance() => create();
  static $pb.PbList<StreamingSynthesizeRequest> createRepeated() => $pb.PbList<StreamingSynthesizeRequest>();
  @$core.pragma('dart2js:noInline')
  static StreamingSynthesizeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StreamingSynthesizeRequest>(create);
  static StreamingSynthesizeRequest? _defaultInstance;

  StreamingSynthesizeRequest_StreamingRequest whichStreamingRequest() => _StreamingSynthesizeRequest_StreamingRequestByTag[$_whichOneof(0)]!;
  void clearStreamingRequest() => clearField($_whichOneof(0));

  /// StreamingSynthesizeConfig to be used in this streaming attempt. Only
  /// specified in the first message sent in a `StreamingSynthesize` call.
  @$pb.TagNumber(1)
  StreamingSynthesizeConfig get streamingConfig => $_getN(0);
  @$pb.TagNumber(1)
  set streamingConfig(StreamingSynthesizeConfig v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasStreamingConfig() => $_has(0);
  @$pb.TagNumber(1)
  void clearStreamingConfig() => clearField(1);
  @$pb.TagNumber(1)
  StreamingSynthesizeConfig ensureStreamingConfig() => $_ensure(0);

  /// Input to synthesize. Specified in all messages but the first in a
  /// `StreamingSynthesize` call.
  @$pb.TagNumber(2)
  StreamingSynthesisInput get input => $_getN(1);
  @$pb.TagNumber(2)
  set input(StreamingSynthesisInput v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasInput() => $_has(1);
  @$pb.TagNumber(2)
  void clearInput() => clearField(2);
  @$pb.TagNumber(2)
  StreamingSynthesisInput ensureInput() => $_ensure(1);
}

/// `StreamingSynthesizeResponse` is the only message returned to the
/// client by `StreamingSynthesize` method. A series of zero or more
/// `StreamingSynthesizeResponse` messages are streamed back to the client.
class StreamingSynthesizeResponse extends $pb.GeneratedMessage {
  factory StreamingSynthesizeResponse({
    $core.List<$core.int>? audioContent,
  }) {
    final $result = create();
    if (audioContent != null) {
      $result.audioContent = audioContent;
    }
    return $result;
  }
  StreamingSynthesizeResponse._() : super();
  factory StreamingSynthesizeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StreamingSynthesizeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StreamingSynthesizeResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.cloud.texttospeech.v1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'audioContent', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StreamingSynthesizeResponse clone() => StreamingSynthesizeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StreamingSynthesizeResponse copyWith(void Function(StreamingSynthesizeResponse) updates) => super.copyWith((message) => updates(message as StreamingSynthesizeResponse)) as StreamingSynthesizeResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamingSynthesizeResponse create() => StreamingSynthesizeResponse._();
  StreamingSynthesizeResponse createEmptyInstance() => create();
  static $pb.PbList<StreamingSynthesizeResponse> createRepeated() => $pb.PbList<StreamingSynthesizeResponse>();
  @$core.pragma('dart2js:noInline')
  static StreamingSynthesizeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StreamingSynthesizeResponse>(create);
  static StreamingSynthesizeResponse? _defaultInstance;

  /// The audio data bytes encoded as specified in the request. This is
  /// headerless LINEAR16 audio with a sample rate of 24000.
  @$pb.TagNumber(1)
  $core.List<$core.int> get audioContent => $_getN(0);
  @$pb.TagNumber(1)
  set audioContent($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAudioContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearAudioContent() => clearField(1);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
