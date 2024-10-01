#!/bin/bash

aws s3 ls | awk '{print $3}' | while read bucket; do
  echo "Đang xử lý bucket: $bucket"
  
  # Xóa tất cả các đối tượng
  aws s3api delete-objects --bucket "$bucket" --delete "$(aws s3api list-object-versions --bucket "$bucket" --output=json --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"
  
  # Xóa tất cả các phiên bản đánh dấu xóa
  aws s3api delete-objects --bucket "$bucket" --delete "$(aws s3api list-object-versions --bucket "$bucket" --output=json --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')"
  
  # Xóa bucket
  aws s3 rb "s3://$bucket" --force
  
  echo "Đã xóa bucket: $bucket"
done