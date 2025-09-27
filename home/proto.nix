{ pkgs, ... }:

{
  home.packages = with pkgs; [
    protobuf
    protoc-gen-go
    protoc-gen-go-grpc
  ];
}
