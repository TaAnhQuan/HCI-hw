//
//  Generated code. Do not modify.
//  source: google/cloud/texttospeech/v1/cloud_tts.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'cloud_tts.pb.dart' as $0;

export 'cloud_tts.pb.dart';

@$pb.GrpcServiceName('google.cloud.texttospeech.v1.TextToSpeech')
class TextToSpeechClient extends $grpc.Client {
  static final _$listVoices = $grpc.ClientMethod<$0.ListVoicesRequest, $0.ListVoicesResponse>(
      '/google.cloud.texttospeech.v1.TextToSpeech/ListVoices',
      ($0.ListVoicesRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListVoicesResponse.fromBuffer(value));
  static final _$synthesizeSpeech = $grpc.ClientMethod<$0.SynthesizeSpeechRequest, $0.SynthesizeSpeechResponse>(
      '/google.cloud.texttospeech.v1.TextToSpeech/SynthesizeSpeech',
      ($0.SynthesizeSpeechRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.SynthesizeSpeechResponse.fromBuffer(value));
  static final _$streamingSynthesize = $grpc.ClientMethod<$0.StreamingSynthesizeRequest, $0.StreamingSynthesizeResponse>(
      '/google.cloud.texttospeech.v1.TextToSpeech/StreamingSynthesize',
      ($0.StreamingSynthesizeRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.StreamingSynthesizeResponse.fromBuffer(value));

  TextToSpeechClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.ListVoicesResponse> listVoices($0.ListVoicesRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listVoices, request, options: options);
  }

  $grpc.ResponseFuture<$0.SynthesizeSpeechResponse> synthesizeSpeech($0.SynthesizeSpeechRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$synthesizeSpeech, request, options: options);
  }

  $grpc.ResponseStream<$0.StreamingSynthesizeResponse> streamingSynthesize($async.Stream<$0.StreamingSynthesizeRequest> request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$streamingSynthesize, request, options: options);
  }
}

@$pb.GrpcServiceName('google.cloud.texttospeech.v1.TextToSpeech')
abstract class TextToSpeechServiceBase extends $grpc.Service {
  $core.String get $name => 'google.cloud.texttospeech.v1.TextToSpeech';

  TextToSpeechServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ListVoicesRequest, $0.ListVoicesResponse>(
        'ListVoices',
        listVoices_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListVoicesRequest.fromBuffer(value),
        ($0.ListVoicesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SynthesizeSpeechRequest, $0.SynthesizeSpeechResponse>(
        'SynthesizeSpeech',
        synthesizeSpeech_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SynthesizeSpeechRequest.fromBuffer(value),
        ($0.SynthesizeSpeechResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StreamingSynthesizeRequest, $0.StreamingSynthesizeResponse>(
        'StreamingSynthesize',
        streamingSynthesize,
        true,
        true,
        ($core.List<$core.int> value) => $0.StreamingSynthesizeRequest.fromBuffer(value),
        ($0.StreamingSynthesizeResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.ListVoicesResponse> listVoices_Pre($grpc.ServiceCall call, $async.Future<$0.ListVoicesRequest> request) async {
    return listVoices(call, await request);
  }

  $async.Future<$0.SynthesizeSpeechResponse> synthesizeSpeech_Pre($grpc.ServiceCall call, $async.Future<$0.SynthesizeSpeechRequest> request) async {
    return synthesizeSpeech(call, await request);
  }

  $async.Future<$0.ListVoicesResponse> listVoices($grpc.ServiceCall call, $0.ListVoicesRequest request);
  $async.Future<$0.SynthesizeSpeechResponse> synthesizeSpeech($grpc.ServiceCall call, $0.SynthesizeSpeechRequest request);
  $async.Stream<$0.StreamingSynthesizeResponse> streamingSynthesize($grpc.ServiceCall call, $async.Stream<$0.StreamingSynthesizeRequest> request);
}
