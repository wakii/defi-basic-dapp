import { PageHeader } from "antd";
import React from "react";

// displays a page header

export default function Header() {
  return (
    <a href="/" /*target="_blank" rel="noopener noreferrer"*/>
      <PageHeader
        title="🏗 wakii-dapp"
        subTitle="Basic Staking App for education, front-end w/ scaffold-eth"
        style={{ cursor: "pointer" }}
      />
    </a>
  );
}
